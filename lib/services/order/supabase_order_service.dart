import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/order.dart';
import 'order_service.dart';

/// Production order service fetching customer orders via Supabase RLS.
/// Order creation is executed by the trusted backend during checkout session creation.
class SupabaseOrderService implements OrderService {
  final SupabaseClient _client;
  final List<OrderModel> _cachedOrders = [];

  SupabaseOrderService(this._client);

  @override
  Future<List<OrderModel>> fetchOrders({String? userId}) async {
    final uid = userId ?? _client.auth.currentUser?.id;
    if (uid == null) {
      return List.unmodifiable(_cachedOrders);
    }

    try {
      final response = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', uid)
          .order('created_at', ascending: false);

      final list = (response as List<dynamic>).map((row) {
        final itemsList = (row['order_items'] as List<dynamic>?)
                ?.map((it) => OrderItemModel.fromJson(it))
                .toList() ??
            [];

        return OrderModel(
          id: row['id']?.toString() ?? '',
          userId: row['user_id']?.toString(),
          customerEmail: row['customer_email']?.toString() ?? '',
          customerName: row['customer_name']?.toString() ?? '',
          subtotal: (row['subtotal'] as num?)?.toDouble() ?? 0.0,
          tax: (row['tax'] as num?)?.toDouble() ?? 0.0,
          shipping: (row['shipping'] as num?)?.toDouble() ?? 0.0,
          totalAmount: (row['total_amount'] as num?)?.toDouble() ?? 0.0,
          status: row['status']?.toString() ?? 'pending',
          stripePaymentId: row['stripe_payment_id']?.toString(),
          shippingAddress: row['shipping_address'] as Map<String, dynamic>?,
          items: itemsList,
          createdAt: row['created_at'] != null
              ? DateTime.tryParse(row['created_at']) ?? DateTime.now()
              : DateTime.now(),
        );
      }).toList();

      // Merge with any cached pending orders not yet indexed
      final existingIds = list.map((o) => o.id).toSet();
      for (final cached in _cachedOrders) {
        if (!existingIds.contains(cached.id)) {
          list.insert(0, cached);
        }
      }

      return list;
    } catch (e) {
      debugPrint('Error fetching orders from Supabase: $e');
      return List.unmodifiable(_cachedOrders);
    }
  }

  @override
  Future<bool> saveOrder(OrderModel order) async {
    // Cache order locally for immediate UI display
    _cachedOrders.removeWhere((o) => o.id == order.id);
    _cachedOrders.insert(0, order);
    return true;
  }
}
