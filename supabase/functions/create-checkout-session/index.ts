import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';
import { calculateOrderDetails, ProductRecord } from '../_shared/pricing.ts';

const STORE_FRONTEND_URL = Deno.env.get('STORE_FRONTEND_URL') || 'https://ivorynails.com';

function sanitizeRedirectUrl(url: string | undefined, defaultSuffix: string): string {
  if (!url) return `${STORE_FRONTEND_URL}${defaultSuffix}`;
  try {
    const parsed = new URL(url);
    if (
      parsed.origin === STORE_FRONTEND_URL ||
      parsed.hostname === 'localhost' ||
      parsed.hostname === '127.0.0.1' ||
      parsed.hostname.endsWith('.ivorynails.com')
    ) {
      return url;
    }
  } catch {
    // Invalid URL
  }
  return `${STORE_FRONTEND_URL}${defaultSuffix}`;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const stripeSecretKey = Deno.env.get('STRIPE_SECRET_KEY');
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseServiceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

    if (!stripeSecretKey) {
      return new Response(
        JSON.stringify({ error: 'Stripe secret key not configured on backend.' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    if (!supabaseUrl || !supabaseServiceRoleKey) {
      return new Response(
        JSON.stringify({ error: 'Supabase service credentials not configured on backend.' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const body = await req.json();
    const {
      items,
      promoCode,
      customerEmail,
      customerName,
      shippingAddress,
      successUrl,
      cancelUrl,
    } = body;

    if (!customerEmail || !customerEmail.includes('@')) {
      return new Response(
        JSON.stringify({ error: 'A valid customer email is required.' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    if (!items || !Array.isArray(items) || items.length === 0) {
      return new Response(
        JSON.stringify({ error: 'Shopping bag items are required.' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Initialize privileged Supabase client
    const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

    // Cryptographic JWT caller verification (prevents userId spoofing)
    let verifiedUserId: string | null = null;
    const authHeader = req.headers.get('authorization');
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7).trim();
      if (token) {
        try {
          const { data: userData, error: userError } = await supabase.auth.getUser(token);
          if (!userError && userData?.user?.id) {
            verifiedUserId = userData.user.id;
          }
        } catch {
          // Token invalid; guest checkout
        }
      }
    }

    // Fetch verified products from DB
    const productIds = items.map((i: any) => i.productId);
    const { data: dbProductsData, error: dbError } = await supabase
      .from('products')
      .select('id, name, price, in_stock, image_url')
      .in('id', productIds);

    if (dbError || !dbProductsData) {
      return new Response(
        JSON.stringify({ error: 'Failed to retrieve products from catalog.' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const dbProductsMap = new Map<string, ProductRecord>();
    for (const p of dbProductsData) {
      dbProductsMap.set(p.id, p);
    }

    // Authoritative server-side price calculation
    const calculatedOrder = calculateOrderDetails(items, dbProductsMap, promoCode);

    // Generate unique order ID
    const randomSuffix = Math.floor(1000 + Math.random() * 9000);
    const orderId = `IVORY-${randomSuffix}`;

    // Create Stripe Checkout Session
    const stripeParams = new URLSearchParams();
    stripeParams.append('mode', 'payment');
    stripeParams.append('customer_email', customerEmail.trim());
    stripeParams.append('client_reference_id', orderId);
    stripeParams.append('metadata[order_id]', orderId);
    stripeParams.append('metadata[customer_email]', customerEmail.trim());
    if (verifiedUserId) {
      stripeParams.append('metadata[user_id]', verifiedUserId);
    }

    // Add line items
    for (let i = 0; i < calculatedOrder.items.length; i++) {
      const item = calculatedOrder.items[i];
      const unitAmountCents = Math.round(item.unitPrice * 100);
      stripeParams.append(`line_items[${i}][price_data][currency]`, 'usd');
      stripeParams.append(`line_items[${i}][price_data][product_data][name]`, item.productName);
      if (item.imageUrl) {
        stripeParams.append(`line_items[${i}][price_data][product_data][images][0]`, item.imageUrl);
      }
      stripeParams.append(`line_items[${i}][price_data][unit_amount]`, unitAmountCents.toString());
      stripeParams.append(`line_items[${i}][quantity]`, item.quantity.toString());
    }

    // Add shipping & taxes
    let lineIndex = calculatedOrder.items.length;
    if (calculatedOrder.shipping > 0) {
      const shippingCents = Math.round(calculatedOrder.shipping * 100);
      stripeParams.append(`line_items[${lineIndex}][price_data][currency]`, 'usd');
      stripeParams.append(`line_items[${lineIndex}][price_data][product_data][name]`, 'Standard Shipping');
      stripeParams.append(`line_items[${lineIndex}][price_data][unit_amount]`, shippingCents.toString());
      stripeParams.append(`line_items[${lineIndex}][quantity]`, '1');
      lineIndex++;
    }
    if (calculatedOrder.tax > 0) {
      const taxCents = Math.round(calculatedOrder.tax * 100);
      stripeParams.append(`line_items[${lineIndex}][price_data][currency]`, 'usd');
      stripeParams.append(`line_items[${lineIndex}][price_data][product_data][name]`, 'Estimated Sales Tax (8%)');
      stripeParams.append(`line_items[${lineIndex}][price_data][unit_amount]`, taxCents.toString());
      stripeParams.append(`line_items[${lineIndex}][quantity]`, '1');
      lineIndex++;
    }

    // Open redirect protection: sanitize URLs
    const safeSuccess = sanitizeRedirectUrl(
      successUrl,
      '/?session_id={CHECKOUT_SESSION_ID}&status=success'
    );
    const safeCancel = sanitizeRedirectUrl(cancelUrl, '/?status=cancelled');
    stripeParams.append('success_url', safeSuccess);
    stripeParams.append('cancel_url', safeCancel);

    const stripeResponse = await fetch('https://api.stripe.com/v1/checkout/sessions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${stripeSecretKey}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: stripeParams.toString(),
    });

    const stripeSession = await stripeResponse.json();

    if (!stripeResponse.ok || !stripeSession.id) {
      const msg = stripeSession.error?.message || 'Failed to create Stripe Checkout session';
      return new Response(
        JSON.stringify({ error: msg }),
        { status: 502, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Persist pending order with verified user ID
    const { error: orderInsertError } = await supabase.from('orders').insert({
      id: orderId,
      user_id: verifiedUserId,
      customer_email: customerEmail.trim(),
      customer_name: customerName || customerEmail.split('@')[0],
      subtotal: calculatedOrder.subtotal,
      tax: calculatedOrder.tax,
      shipping: calculatedOrder.shipping,
      total_amount: calculatedOrder.totalAmount,
      status: 'pending',
      stripe_payment_id: stripeSession.id,
      shipping_address: shippingAddress || null,
      created_at: new Date().toISOString(),
    });

    if (orderInsertError) {
      console.error('Failed to create pending order record:', orderInsertError);
    } else {
      const orderItemsPayload = calculatedOrder.items.map((it) => ({
        order_id: orderId,
        product_id: it.productId,
        product_name: it.productName,
        quantity: it.quantity,
        unit_price: it.unitPrice,
        total_price: it.totalPrice,
      }));
      await supabase.from('order_items').insert(orderItemsPayload);
    }

    return new Response(
      JSON.stringify({
        checkoutUrl: stripeSession.url,
        sessionId: stripeSession.id,
        orderId,
        totalAmount: calculatedOrder.totalAmount,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (err: any) {
    return new Response(
      JSON.stringify({ error: err.message || 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});
