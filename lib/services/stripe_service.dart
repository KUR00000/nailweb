import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import 'integration_service.dart';

/// Payment result container returned after Stripe execution.
class StripePaymentResult {
  final bool isSuccess;
  final bool isRedirect;
  final String? checkoutUrl;
  final String? paymentIntentId;
  final String? errorMessage;
  final OrderModel? completedOrder;
  final bool isSimulated;

  const StripePaymentResult({
    required this.isSuccess,
    this.isRedirect = false,
    this.checkoutUrl,
    this.paymentIntentId,
    this.errorMessage,
    this.completedOrder,
    this.isSimulated = false,
  });
}

/// Service handling Stripe Checkout and Web Payment processing.
/// Delegates to the BYOK PaymentService abstraction.
class StripeService {
  static final StripeService _instance = StripeService._internal();
  factory StripeService() => _instance;
  StripeService._internal();

  final IntegrationService _integration = IntegrationService();

  /// Launch external hosted Stripe Checkout session URL
  Future<bool> launchStripeHostedCheckout(String checkoutUrl) async {
    try {
      final uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Error launching Stripe Checkout URL: $e');
    }
    return false;
  }

  /// Process payment via Stripe Elements / Checkout.
  /// Calls the active BYOK payment service.
  Future<StripePaymentResult> processPayment({
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
    final result = await _integration.paymentService.processPayment(
      cartItems: cartItems,
      subtotal: subtotal,
      tax: tax,
      shipping: shipping,
      totalAmount: totalAmount,
      cardholderName: cardholderName,
      cardNumber: cardNumber,
      expiryDate: expiryDate,
      cvc: cvc,
      postalCode: postalCode,
      customerEmail: customerEmail,
      customerName: customerName,
      shippingAddress: shippingAddress,
      promoCode: promoCode,
    );

    return StripePaymentResult(
      isSuccess: result.isSuccess,
      isRedirect: result.isRedirect,
      checkoutUrl: result.checkoutUrl,
      paymentIntentId: result.paymentIntentId,
      errorMessage: result.errorMessage,
      completedOrder: result.completedOrder,
      isSimulated: result.isSimulated,
    );
  }
}
