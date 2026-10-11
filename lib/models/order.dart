/// Represents an individual item within a completed order.
class OrderItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? imageUrl;

  const OrderItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.imageUrl,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name'] ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'image_url': imageUrl,
    };
  }
}

/// Order record created upon successful checkout via Stripe and saved to Supabase.
class OrderModel {
  final String id;
  final String? userId;
  final String customerEmail;
  final String customerName;
  final double subtotal;
  final double tax;
  final double shipping;
  final double totalAmount;
  final String status;
  final String? stripePaymentId;
  final Map<String, dynamic>? shippingAddress;
  final List<OrderItemModel> items;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    this.userId,
    required this.customerEmail,
    required this.customerName,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.totalAmount,
    this.status = 'paid',
    this.stripePaymentId,
    this.shippingAddress,
    required this.items,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['user_id'],
      customerEmail: json['customer_email'] ?? '',
      customerName: json['customer_name'] ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      shipping: (json['shipping'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'paid',
      stripePaymentId: json['stripe_payment_id'],
      shippingAddress: json['shipping_address'] as Map<String, dynamic>?,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'customer_email': customerEmail,
      'customer_name': customerName,
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'total_amount': totalAmount,
      'status': status,
      'stripe_payment_id': stripePaymentId,
      'shipping_address': shippingAddress,
      'items': items.map((i) => i.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
