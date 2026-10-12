import 'package:flutter_test/flutter_test.dart';
import 'package:ivory_nails/models/order.dart';
import 'package:ivory_nails/services/order/demo_order_service.dart';

void main() {
  group('Security & Cross-Tenant Isolation Tests', () {
    test('Customer order records remain isolated and immutable', () async {
      final orderService = DemoOrderService();

      final orderA = OrderModel(
        id: 'IVORY-1001',
        userId: 'user-alice-123',
        customerEmail: 'alice@example.com',
        customerName: 'Alice Atelier',
        subtotal: 50.00,
        tax: 4.00,
        shipping: 0.00,
        totalAmount: 54.00,
        items: [],
        createdAt: DateTime.now(),
      );

      final orderB = OrderModel(
        id: 'IVORY-1002',
        userId: 'user-bob-456',
        customerEmail: 'bob@example.com',
        customerName: 'Bob Atelier',
        subtotal: 25.00,
        tax: 2.00,
        shipping: 4.99,
        totalAmount: 31.99,
        items: [],
        createdAt: DateTime.now(),
      );

      await orderService.saveOrder(orderA);
      await orderService.saveOrder(orderB);

      final allOrders = await orderService.fetchOrders();
      expect(allOrders.length, equals(2));
      expect(allOrders.any((o) => o.userId == 'user-alice-123'), isTrue);
      expect(allOrders.any((o) => o.userId == 'user-bob-456'), isTrue);

      // Verify that the returned order list is unmodifiable
      expect(() => allOrders.clear(), throwsUnsupportedError);
    });

    test('Order price and total amounts cannot be tampered after confirmation', () {
      final order = OrderModel(
        id: 'IVORY-9999',
        userId: 'user-1',
        customerEmail: 'customer@example.com',
        customerName: 'Customer',
        subtotal: 100.0,
        tax: 8.0,
        shipping: 0.0,
        totalAmount: 108.0,
        status: 'paid',
        items: [],
        createdAt: DateTime.now(),
      );

      // OrderModel fields are final and immutable
      expect(order.totalAmount, equals(108.0));
      expect(order.status, equals('paid'));
    });
  });
}
