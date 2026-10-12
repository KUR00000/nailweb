import 'dart:math';
import '../../models/cart_item.dart';
import '../../models/order.dart';
import '../order/order_service.dart';
import 'payment_service.dart';

/// Payment service for Atelier Demo mode.
/// Performs local simulated checkout with clear demo tagging and zero external requests.
class DemoPaymentService implements PaymentService {
  final OrderService _orderService;

  DemoPaymentService(this._orderService);

  @override
  bool get canProcessRealPayments => false;

  @override
  bool get isDemo => true;

  @override
  Future<PaymentResult> processPayment({
    required List<CartItem> cartItems,
    required double subtotal,
    required double tax,
    required double shipping,
    required double totalAmount,
    required String cardholderName,
    required String cardNumber,
    required String expiryDate,
    required String cvc,
    required String postalCode,
    required String customerEmail,
    String? customerName,
    Map<String, dynamic>? shippingAddress,
    String? promoCode,
  }) async {
    // 1. Client-side Luhn / basic sanity check
    final cleanCard = cardNumber.replaceAll(RegExp(r'\s+'), '');
    if (cleanCard.length < 15) {
      return const PaymentResult(
        isSuccess: false,
        errorMessage: 'Please enter a valid 16-digit card number.',
        isSimulated: true,
      );
    }

    if (cvc.length < 3) {
      return const PaymentResult(
        isSuccess: false,
        errorMessage: 'Invalid CVV/CVC security code.',
        isSimulated: true,
      );
    }

    // 2. Realistic test round-trip latency
    await Future.delayed(const Duration(milliseconds: 1200));

    // Simulated Stripe decline test condition (card ending in 0000)
    if (cleanCard.endsWith('0000')) {
      return const PaymentResult(
        isSuccess: false,
        errorMessage: 'Card was declined by issuing bank (Simulated test card ending in 0000).',
        isSimulated: true,
      );
    }

    // 3. Generate Simulated Order Reference & Payment ID
    final random = Random();
    final orderReferenceNumber = 'IVORY-${1000 + random.nextInt(8999)}';
    final simulatedStripePi =
        'pi_3N${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}_${random.nextInt(999999)}';

    final orderItems = cartItems
        .map(
          (ci) => OrderItemModel(
            productId: ci.product.id,
            productName: ci.product.name,
            quantity: ci.quantity,
            unitPrice: ci.product.price,
            totalPrice: ci.totalPrice,
            imageUrl: ci.product.imageUrl,
          ),
        )
        .toList();

    final order = OrderModel(
      id: orderReferenceNumber,
      userId: null,
      customerEmail: customerEmail.trim(),
      customerName: customerName ?? cardholderName,
      subtotal: subtotal,
      tax: tax,
      shipping: shipping,
      totalAmount: totalAmount,
      status: 'paid',
      stripePaymentId: simulatedStripePi,
      shippingAddress: shippingAddress ?? {'postal_code': postalCode},
      items: orderItems,
      createdAt: DateTime.now(),
    );

    // Save to demo orders
    await _orderService.saveOrder(order);

    return PaymentResult(
      isSuccess: true,
      paymentIntentId: simulatedStripePi,
      completedOrder: order,
      isSimulated: true,
    );
  }
}
