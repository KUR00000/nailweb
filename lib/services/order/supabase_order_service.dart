import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/order.dart';
import 'order_service.dart';

/// Production order service fetching customer orders via Supabase RLS.
class SupabaseOrderService implements OrderService {
  final SupabaseClient _client;

  SupabaseOrderService(this._client);

  @override
  Future<List<OrderModel>> fetchOrders({String? userId}) async {
    final uid = userId ?? _client.auth.currentUser?.id;
    if (uid == null) {
      return [];
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

      return list;
    } catch (e) {
      debugPrint('Error fetching orders from Supabase: $e');
      return [];
    }
  }

  @override
  Future<bool> saveOrder(OrderModel order) async {
    try {
      await _client.from('orders').insert({
        'id': order.id,
        'user_id': _client.auth.currentUser?.id,
        'customer_email': order.customerEmail,
        'customer_name': order.customerName,
        'subtotal': order.subtotal,
        'tax': order.tax,
        'shipping': order.shipping,
        'total_amount': order.totalAmount,
        'status': order.status,
        'stripe_payment_id': order.stripePaymentId,
        'shipping_address': order.shippingAddress,
        'created_at': order.createdAt.toIso8601String(),
      });

      if (order.items.isNotEmpty) {
        final itemsPayload = order.items.map((item) => {
              'order_id': order.id,
              'product_id': item.productId,
              'product_name': item.productName,
              'quantity': item.quantity,
              'unit_price': item.unitPrice,
              'total_price': item.totalPrice,
            }).toList();

        await _client.from('order_items').insert(itemsPayload);
      }
      return true;
    } catch (e) {
      debugPrint('Failed to save order to Supabase: $e');
      return false;
    }
  }
}
