import '../../models/order.dart';
import 'order_service.dart';

/// In-memory order service for Atelier Demo mode.
class DemoOrderService implements OrderService {
  final List<OrderModel> _demoOrders = [];

  @override
  Future<List<OrderModel>> fetchOrders({String? userId}) async {
    return List.unmodifiable(_demoOrders);
  }

  @override
  Future<bool> saveOrder(OrderModel order) async {
    _demoOrders.insert(0, order);
    return true;
  }
}
