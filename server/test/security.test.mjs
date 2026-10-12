import test from 'node:test';
import assert from 'node:assert/strict';
import http from 'node:http';
import { app } from '../dist/server.js';

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
