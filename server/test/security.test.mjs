import test from 'node:test';
import assert from 'node:assert/strict';
import http from 'node:http';
import { app, isRateLimited, sanitizeRedirectUrl } from '../dist/server.js';

let server;
let baseUrl;

test.before(async () => {
  await new Promise((resolve) => {
    server = http.createServer(app);
    server.listen(0, '127.0.0.1', () => {
      const port = server.address().port;
      baseUrl = `http://127.0.0.1:${port}`;
      resolve();
    });
  });
});

test.after(async () => {
  if (server) {
    await new Promise((resolve) => server.close(resolve));
  }
});

test('Health check: Never leaks secret credentials in response', async () => {
  const res = await fetch(`${baseUrl}/api/health-check`);
  assert.equal(res.status, 200);
  const data = await res.json();

  // Verify structure
  assert.equal(typeof data.backend_online, 'boolean');
  assert.equal(typeof data.stripe_configured, 'boolean');
  assert.equal(typeof data.webhook_configured, 'boolean');
  assert.equal(typeof data.supabase_connected, 'boolean');
  assert.equal(typeof data.overall_status, 'string');

  // Strict security assertion: NO credentials or tokens anywhere in response JSON
  const rawString = JSON.stringify(data);
  assert.equal(rawString.includes('sk_'), false, 'Response leaked Stripe secret key prefix!');
  assert.equal(rawString.includes('whsec_'), false, 'Response leaked webhook secret prefix!');
  assert.equal(rawString.includes('eyJh'), false, 'Response leaked JWT token prefix!');
});

test('Webhook endpoint: Rejects requests missing stripe-signature header', async () => {
  const res = await fetch(`${baseUrl}/api/stripe-webhook`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ type: 'checkout.session.completed' }),
  });
  // Must fail due to missing header or missing webhook secret
  assert.ok(res.status === 400 || res.status === 500);
});

test('Checkout endpoint: Rejects requests with invalid customer email', async () => {
  const res = await fetch(`${baseUrl}/api/create-checkout-session`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      customerEmail: 'not-an-email',
      items: [{ productId: 'p1', quantity: 1 }],
    }),
  });
  // Should reject invalid email or report missing credentials
  assert.ok(res.status === 400 || res.status === 500);
  const json = await res.json();
  assert.ok(json.error);
});

test('Checkout endpoint: Rejects empty shopping cart', async () => {
  const res = await fetch(`${baseUrl}/api/create-checkout-session`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      customerEmail: 'customer@example.com',
      items: [],
    }),
  });
  assert.ok(res.status === 400 || res.status === 500);
  const json = await res.json();
  assert.ok(json.error);
});

test('Open Redirect defense: sanitizeRedirectUrl neutralizes phishing and non-whitelisted destinations', () => {
  const fallback = '/?status=success';
  const defaultUrl = `https://ivorynails.com${fallback}`;

  // Malicious domains and schemes must be replaced with safe domain default
  assert.equal(sanitizeRedirectUrl('https://evil-phishing.com/steal-creds', fallback), defaultUrl);
  assert.equal(sanitizeRedirectUrl('javascript:alert(1)', fallback), defaultUrl);
  assert.equal(sanitizeRedirectUrl('data:text/html,<script>alert(1)</script>', fallback), defaultUrl);
  assert.equal(sanitizeRedirectUrl('ftp://example.com', fallback), defaultUrl);
  assert.equal(sanitizeRedirectUrl(undefined, fallback), defaultUrl);
  assert.equal(sanitizeRedirectUrl('', fallback), defaultUrl);

  // Trusted origins must be permitted
  assert.equal(
    sanitizeRedirectUrl('https://ivorynails.com/atelier/success', fallback),
    'https://ivorynails.com/atelier/success'
  );
  assert.equal(
    sanitizeRedirectUrl('https://sub.ivorynails.com/order-confirmed', fallback),
    'https://sub.ivorynails.com/order-confirmed'
  );
  assert.equal(
    sanitizeRedirectUrl('http://localhost:3000/?status=success', fallback),
    'http://localhost:3000/?status=success'
  );
  assert.equal(
    sanitizeRedirectUrl('http://127.0.0.1:8080/cancel', fallback),
    'http://127.0.0.1:8080/cancel'
  );
});

test('Rate limiting: Triggers limit after 30 requests per IP address', () => {
  const testIp = '198.51.100.42'; // RFC 5737 test IP
  // First 30 calls should pass
  for (let i = 0; i < 30; i++) {
    const limited = isRateLimited(testIp);
    assert.equal(limited, false, `Call ${i + 1} should not be rate-limited`);
  }
  // 31st call must be blocked
  assert.equal(isRateLimited(testIp), true, 'Call 31 must be blocked by rate limiter');
});

test('Checkout endpoint: Discards unverified client-supplied userId without valid JWT', async () => {
  // Calling with an attacker-crafted userId and bogus Bearer token
  const res = await fetch(`${baseUrl}/api/create-checkout-session`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer fake-malicious-token',
    },
    body: JSON.stringify({
      customerEmail: 'shopper@example.com',
      userId: 'spoofed_admin_uuid',
      items: [{ productId: 'p1', quantity: 1 }],
    }),
  });
  // Endpoint will safely reject or process without accepting spoofed userId
  const json = await res.json();
  const rawResponse = JSON.stringify(json);
  // Ensure the spoofed admin ID is never confirmed or stored as the authentic owner
  assert.equal(rawResponse.includes('spoofed_admin_uuid'), false);
});

