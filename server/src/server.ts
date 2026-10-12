import express, { Request, Response } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import Stripe from 'stripe';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { calculateOrderDetails, ProductRecord } from './pricing';
import { Database } from './types';

dotenv.config();

export const app = express();

const STRIPE_SECRET_KEY = process.env.STRIPE_SECRET_KEY;
const STRIPE_WEBHOOK_SECRET = process.env.STRIPE_WEBHOOK_SECRET;
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
const STORE_FRONTEND_URL = process.env.STORE_FRONTEND_URL || 'https://ivorynails.com';
const ALLOWED_ORIGIN = process.env.ALLOWED_ORIGIN || '*';

// In-memory IP rate limiter to protect against DoS and Stripe API flooding
const rateLimitMap = new Map<string, { count: number; resetAt: number }>();
const RATE_LIMIT_WINDOW_MS = 15 * 60 * 1000; // 15 minutes
const RATE_LIMIT_MAX = 30; // 30 checkout sessions per window

export function isRateLimited(ip: string): boolean {
  const now = Date.now();
  const entry = rateLimitMap.get(ip);
  if (!entry || now > entry.resetAt) {
    rateLimitMap.set(ip, { count: 1, resetAt: now + RATE_LIMIT_WINDOW_MS });
    return false;
  }
  if (entry.count >= RATE_LIMIT_MAX) {
    return true;
  }
  entry.count++;
  return false;
}

// Open redirect validator
export function sanitizeRedirectUrl(url: string | undefined, defaultSuffix: string): string {
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
    // Malformed URL
  }
  return `${STORE_FRONTEND_URL}${defaultSuffix}`;
}

// Initialize Stripe if secret is valid
let stripe: Stripe | null = null;
if (STRIPE_SECRET_KEY && STRIPE_SECRET_KEY.startsWith('sk_')) {
  stripe = new Stripe(STRIPE_SECRET_KEY, {
    apiVersion: '2023-10-16',
  });
}

// Initialize Supabase admin client if configured
let supabaseAdmin: SupabaseClient<Database> | null = null;
if (SUPABASE_URL && SUPABASE_SERVICE_ROLE_KEY) {
  supabaseAdmin = createClient<Database>(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: { persistSession: false },
  });
}

// Webhook route MUST receive raw body for cryptographic signature verification
app.post(
  '/api/stripe-webhook',
  express.raw({ type: 'application/json' }),
  async (req: Request, res: Response) => {
    if (!STRIPE_WEBHOOK_SECRET) {
      return res.status(500).json({ error: 'Webhook secret not configured on backend.' });
    }

    if (!stripe) {
      return res.status(500).json({ error: 'Stripe secret key not configured on backend.' });
    }

    const sig = req.headers['stripe-signature'];
    if (!sig) {
      return res.status(400).json({ error: 'Missing stripe-signature header' });
    }

    let event: Stripe.Event;
    try {
      event = stripe.webhooks.constructEvent(req.body, sig, STRIPE_WEBHOOK_SECRET);
    } catch (err: any) {
      return res.status(401).json({ error: `Webhook signature verification failed: ${err.message}` });
    }

    // Process event idempotently with status transition guards
    try {
      if (event.type === 'checkout.session.completed') {
        const session = event.data.object as Stripe.Checkout.Session;
        const orderId = session.client_reference_id || session.metadata?.order_id;
        const paymentIntentId = (session.payment_intent as string) || session.id;

        if (orderId && supabaseAdmin) {
          // Strictly only transition orders from 'pending' to 'paid'
          // This prevents overwriting orders already marked as 'preparing', 'shipped', or 'delivered'
          await (supabaseAdmin as any)
            .from('orders')
            .update({
              status: 'paid',
              stripe_payment_id: paymentIntentId,
            })
            .eq('id', orderId)
            .eq('status', 'pending');
        }
      } else if (event.type === 'checkout.session.expired') {
        const session = event.data.object as Stripe.Checkout.Session;
        const orderId = session.client_reference_id || session.metadata?.order_id;

        if (orderId && supabaseAdmin) {
          await (supabaseAdmin as any)
            .from('orders')
            .update({ status: 'cancelled' })
            .eq('id', orderId)
            .eq('status', 'pending');
        }
      }

      return res.status(200).json({ received: true });
    } catch (err: any) {
      return res.status(500).json({ error: `Error processing event: ${err.message}` });
    }
  }
);

// Standard JSON parsing and CORS for other routes
app.use(cors({ origin: ALLOWED_ORIGIN }));
app.use(express.json());

// Health & diagnostics endpoint
app.get(['/health', '/api/health-check'], async (_req: Request, res: Response) => {
  const stripeConfigured = Boolean(STRIPE_SECRET_KEY && STRIPE_SECRET_KEY.startsWith('sk_'));
  const stripeMode = STRIPE_SECRET_KEY
    ? STRIPE_SECRET_KEY.startsWith('sk_test_')
      ? 'test'
      : 'live'
    : 'none';
  const webhookConfigured = Boolean(
    STRIPE_WEBHOOK_SECRET && STRIPE_WEBHOOK_SECRET.startsWith('whsec_')
  );

  let supabaseConnected = false;
  let schemaReady = false;
  let rlsEnforced = false;
  let productsCount = 0;

  if (supabaseAdmin) {
    try {
      const { data, error } = await (supabaseAdmin as any).rpc('check_atelier_schema_status');
      if (!error && data) {
        supabaseConnected = true;
        schemaReady = (data as any).tables_valid === true;
        rlsEnforced = (data as any).rls_enforced === true;
        productsCount = (data as any).products_count || 0;
      } else {
        const { count, error: cErr } = await supabaseAdmin
          .from('products')
          .select('*', { count: 'exact', head: true });
        if (!cErr) {
          supabaseConnected = true;
          productsCount = count || 0;
        }
      }
    } catch {
      supabaseConnected = false;
    }
  }

  let overallStatus = 'missing_configuration';
  if (!supabaseConnected) {
    overallStatus = 'administrative_setup_required';
  } else if (!stripeConfigured || !webhookConfigured) {
    overallStatus = 'connected_service';
  } else if (!schemaReady || !rlsEnforced) {
    overallStatus = 'administrative_setup_required';
  } else {
    overallStatus = 'production_ready';
  }

  // Redacted diagnostics — NO CREDENTIALS EVER LEAKED
  return res.status(200).json({
    timestamp: new Date().toISOString(),
    backend_online: true,
    stripe_configured: stripeConfigured,
    stripe_mode: stripeMode,
    webhook_configured: webhookConfigured,
    supabase_connected: supabaseConnected,
    schema_ready: schemaReady,
    rls_enforced: rlsEnforced,
    products_count: productsCount,
    overall_status: overallStatus,
  });
});

// Checkout session creation endpoint
app.post('/api/create-checkout-session', async (req: Request, res: Response) => {
  try {
    // 1. Rate limiting check
    const clientIp = req.ip || req.socket.remoteAddress || 'unknown';
    if (isRateLimited(clientIp)) {
      return res.status(429).json({
        error: 'Too many checkout attempts. Please wait a few moments before trying again.',
      });
    }

    if (!stripe) {
      return res.status(500).json({
        error: 'Stripe secret key not configured on trusted backend.',
      });
    }

    if (!supabaseAdmin) {
      return res.status(500).json({
        error: 'Supabase service role credentials not configured on trusted backend.',
      });
    }

    const {
      items,
      promoCode,
      customerEmail,
      customerName,
      shippingAddress,
      successUrl,
      cancelUrl,
    } = req.body;

    if (!customerEmail || !customerEmail.includes('@')) {
      return res.status(400).json({ error: 'Valid customer email is required.' });
    }

    if (!items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ error: 'Shopping bag items are required.' });
    }

    // 2. Cryptographic user identity verification (prevents userId spoofing)
    let verifiedUserId: string | null = null;
    const authHeader = req.headers['authorization'];
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7).trim();
      if (token) {
        try {
          const { data: userData, error: userError } = await supabaseAdmin.auth.getUser(token);
          if (!userError && userData?.user?.id) {
            verifiedUserId = userData.user.id;
          }
        } catch {
          // Token invalid; verifiedUserId remains null for guest checkout
        }
      }
    }

    // 3. Retrieve authoritative products from catalog in Supabase
    const productIds: string[] = items.map((i: any) => i.productId);
    const { data: dbProductsData, error: dbError } = await supabaseAdmin
      .from('products')
      .select('id, name, price, in_stock, image_url')
      .in('id', productIds);

    if (dbError || !dbProductsData) {
      return res.status(500).json({ error: 'Failed to retrieve products from catalog.' });
    }

    const dbProductsMap = new Map<string, ProductRecord>();
    for (const p of dbProductsData as any[]) {
      dbProductsMap.set(p.id, p);
    }

    // 4. Server-side authoritative price calculation (Prevents client price/quantity tampering)
    const calculatedOrder = calculateOrderDetails(items, dbProductsMap, promoCode);

    const randomSuffix = Math.floor(1000 + Math.random() * 9000);
    const orderId = `IVORY-${randomSuffix}`;

    // 5. Build Stripe Line Items
    const lineItems: Stripe.Checkout.SessionCreateParams.LineItem[] = calculatedOrder.items.map(
      (item) => ({
        price_data: {
          currency: 'usd',
          unit_amount: Math.round(item.unitPrice * 100),
          product_data: {
            name: item.productName,
            images: item.imageUrl ? [item.imageUrl] : [],
          },
        },
        quantity: item.quantity,
      })
    );

    if (calculatedOrder.shipping > 0) {
      lineItems.push({
        price_data: {
          currency: 'usd',
          unit_amount: Math.round(calculatedOrder.shipping * 100),
          product_data: { name: 'Standard Shipping' },
        },
        quantity: 1,
      });
    }

    if (calculatedOrder.tax > 0) {
      lineItems.push({
        price_data: {
          currency: 'usd',
          unit_amount: Math.round(calculatedOrder.tax * 100),
          product_data: { name: 'Estimated Sales Tax (8%)' },
        },
        quantity: 1,
      });
    }

    // 6. Open redirect protection: sanitize return URLs
    const safeSuccessUrl = sanitizeRedirectUrl(
      successUrl,
      '/?session_id={CHECKOUT_SESSION_ID}&status=success'
    );
    const safeCancelUrl = sanitizeRedirectUrl(cancelUrl, '/?status=cancelled');

    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      mode: 'payment',
      customer_email: customerEmail.trim(),
      client_reference_id: orderId,
      metadata: {
        order_id: orderId,
        customer_email: customerEmail.trim(),
        user_id: verifiedUserId || '',
      },
      line_items: lineItems,
      success_url: safeSuccessUrl,
      cancel_url: safeCancelUrl,
    });

    // 7. Save pending order to Supabase using verified identity
    await (supabaseAdmin as any).from('orders').insert({
      id: orderId,
      user_id: verifiedUserId,
      customer_email: customerEmail.trim(),
      customer_name: customerName || customerEmail.split('@')[0],
      subtotal: calculatedOrder.subtotal,
      tax: calculatedOrder.tax,
      shipping: calculatedOrder.shipping,
      total_amount: calculatedOrder.totalAmount,
      status: 'pending',
      stripe_payment_id: session.id,
      shipping_address: shippingAddress || null,
      created_at: new Date().toISOString(),
    });

    const orderItemsPayload = calculatedOrder.items.map((it) => ({
      order_id: orderId,
      product_id: it.productId,
      product_name: it.productName,
      quantity: it.quantity,
      unit_price: it.unitPrice,
      total_price: it.totalPrice,
    }));
    await (supabaseAdmin as any).from('order_items').insert(orderItemsPayload);

    return res.status(200).json({
      checkoutUrl: session.url,
      sessionId: session.id,
      orderId,
      totalAmount: calculatedOrder.totalAmount,
    });
  } catch (err: any) {
    return res.status(500).json({ error: err.message || 'Server error' });
  }
});

// Start listening if run directly
if (require.main === module) {
  const PORT = process.env.PORT || 4242;
  app.listen(PORT, () => {
    console.log(`✨ Ivory Nails Trusted Payments Backend running on port ${PORT}`);
  });
}
