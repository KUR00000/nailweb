import '../../models/order.dart';

/// Abstract order service for fetching customer order history.
abstract class OrderService {
  Future<List<OrderModel>> fetchOrders({String? userId});
  Future<bool> saveOrder(OrderModel order);
}
