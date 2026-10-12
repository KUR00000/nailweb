import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
import { corsHeaders } from '../_shared/cors.ts';

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  const stripeSecretKey = Deno.env.get('STRIPE_SECRET_KEY');
  const stripeWebhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET');
  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const supabaseServiceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

  const diagnostics: Record<string, any> = {
    timestamp: new Date().toISOString(),
    backend_online: true,
    stripe_configured: Boolean(stripeSecretKey && stripeSecretKey.startsWith('sk_')),
    stripe_mode: stripeSecretKey ? (stripeSecretKey.startsWith('sk_test_') ? 'test' : 'live') : 'none',
    webhook_configured: Boolean(stripeWebhookSecret && stripeWebhookSecret.startsWith('whsec_')),
    supabase_connected: false,
    schema_ready: false,
    rls_enforced: false,
    products_count: 0,
    overall_status: 'missing_configuration',
  };

  if (supabaseUrl && supabaseServiceRoleKey) {
    try {
      const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);
      const { data, error } = await supabase.rpc('check_atelier_schema_status');

      if (!error && data) {
        diagnostics.supabase_connected = true;
        diagnostics.schema_ready = data.tables_valid === true;
        diagnostics.rls_enforced = data.rls_enforced === true;
        diagnostics.products_count = data.products_count || 0;
      } else {
        // Fallback check
        const { count, error: countErr } = await supabase.from('products').select('*', { count: 'exact', head: true });
        if (!countErr) {
          diagnostics.supabase_connected = true;
          diagnostics.products_count = count || 0;
        }
      }
    } catch {
      diagnostics.supabase_connected = false;
    }
  }

  // Determine overall status
  if (!diagnostics.supabase_connected) {
    diagnostics.overall_status = 'administrative_setup_required';
  } else if (!diagnostics.stripe_configured || !diagnostics.webhook_configured) {
    diagnostics.overall_status = 'connected_service'; // Database connected, but payment backend incomplete
  } else if (!diagnostics.schema_ready || !diagnostics.rls_enforced) {
    diagnostics.overall_status = 'administrative_setup_required';
  } else {
    diagnostics.overall_status = 'production_ready';
  }

  return new Response(JSON.stringify(diagnostics), {
    status: 200,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
});
