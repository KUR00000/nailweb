import test from 'node:test';
import assert from 'node:assert/strict';
import { calculateOrderDetails } from '../dist/pricing.js';

const mockCatalog = new Map([
  [
    'p1',
    { id: 'p1', name: 'Baby Blossom Polish', price: 14.50, in_stock: true },
  ],
  [
    'p2',
    { id: 'p2', name: 'Rose Quartz Press-Ons', price: 24.00, in_stock: true },
  ],
  [
    'p3',
    { id: 'p3', name: 'Sold Out Polish', price: 10.00, in_stock: false },
  ],
]);

test('Authoritative pricing: calculates subtotal, 8% tax, and shipping correctly', () => {
  const items = [{ productId: 'p1', quantity: 1 }]; // $14.50
  const order = calculateOrderDetails(items, mockCatalog);

  assert.equal(order.items.length, 1);
  assert.equal(order.items[0].unitPrice, 14.50);
  assert.equal(order.subtotal, 14.50);
  assert.equal(order.shipping, 4.99); // Under $50 threshold
  assert.equal(order.tax, 1.16); // 14.50 * 0.08 = 1.16
  assert.equal(order.totalAmount, 20.65); // 14.50 + 1.16 + 4.99
});

test('Free shipping unlocked at or above $50.00', () => {
  const items = [
    { productId: 'p1', quantity: 2 }, // $29.00
    { productId: 'p2', quantity: 1 }, // $24.00 -> total $53.00
  ];
  const order = calculateOrderDetails(items, mockCatalog);

  assert.equal(order.subtotal, 53.00);
  assert.equal(order.shipping, 0.00); // Free shipping!
  assert.equal(order.tax, 4.24); // 53.00 * 0.08 = 4.24
  assert.equal(order.totalAmount, 57.24);
});

test('Validates promo code IVORY10 (10% discount)', () => {
  const items = [{ productId: 'p2', quantity: 2 }]; // $48.00
  const order = calculateOrderDetails(items, mockCatalog, 'IVORY10');

  assert.equal(order.discountPercentage, 0.10);
  assert.equal(order.discountAmount, 4.80);
  assert.equal(order.subtotal, 43.20); // 48.00 - 4.80
  assert.equal(order.appliedPromoCode, 'IVORY10');
});

test('Validates promo code ATELIER20 (20% discount)', () => {
  const items = [{ productId: 'p2', quantity: 2 }]; // $48.00
  const order = calculateOrderDetails(items, mockCatalog, 'ATELIER20');

  assert.equal(order.discountPercentage, 0.20);
  assert.equal(order.discountAmount, 9.60);
  assert.equal(order.subtotal, 38.40);
  assert.equal(order.appliedPromoCode, 'ATELIER20');
});

test('Ignores invalid promo codes without crashing', () => {
  const items = [{ productId: 'p1', quantity: 1 }];
  const order = calculateOrderDetails(items, mockCatalog, 'FAKECODE123');

  assert.equal(order.discountPercentage, 0.0);
  assert.equal(order.discountAmount, 0.0);
  assert.equal(order.appliedPromoCode, null);
});

test('Rejects out-of-stock items', () => {
  const items = [{ productId: 'p3', quantity: 1 }];
  assert.throws(
    () => calculateOrderDetails(items, mockCatalog),
    /is out of stock/
  );
});

test('Rejects price tampering via negative or non-integer quantities', () => {
  assert.throws(
    () => calculateOrderDetails([{ productId: 'p1', quantity: -1 }], mockCatalog),
    /Invalid quantity/
  );
  assert.throws(
    () => calculateOrderDetails([{ productId: 'p1', quantity: 0 }], mockCatalog),
    /Invalid quantity/
  );
  assert.throws(
    () => calculateOrderDetails([{ productId: 'p1', quantity: 1.5 }], mockCatalog),
    /Invalid quantity/
  );
});

test('Rejects empty shopping cart', () => {
  assert.throws(
    () => calculateOrderDetails([], mockCatalog),
    /Shopping bag is empty/
  );
});
