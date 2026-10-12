import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/app_config.dart';
import '../../models/cart_item.dart';
import '../../models/order.dart';
import '../order/order_service.dart';
import 'payment_service.dart';

/// Production payment service communicating with the trusted BYOK payments backend.
/// Generates authoritative server-side Stripe Checkout sessions.
class StripePaymentService implements PaymentService {
  final AppConfig _config;
  final OrderService _orderService;

  StripePaymentService(this._config, this._orderService);

  @override
  bool get canProcessRealPayments =>
      _config.hasValidStripePublishableKey && _config.hasValidPaymentsBackend;

  @override
  bool get isDemo => false;

  /// Launch external hosted Stripe Checkout session URL
  Future<bool> launchHostedCheckout(String checkoutUrl) async {
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
    if (!canProcessRealPayments) {
      return const PaymentResult(
        isSuccess: false,
        errorMessage:
            'Production payment gateway is not fully configured. '
            'Please verify PAYMENTS_BACKEND_URL and STRIPE_PUBLISHABLE_KEY in .env.json.',
      );
    }

    try {
      final endpoint = _config.paymentsBackendUrl.endsWith('/')
          ? '${_config.paymentsBackendUrl}api/create-checkout-session'
          : '${_config.paymentsBackendUrl}/api/create-checkout-session';

      final payload = {
        'items': cartItems
            .map((ci) => {
                  'productId': ci.product.id,
                  'quantity': ci.quantity,
                })
            .toList(),
        'promoCode': promoCode,
        'customerEmail': customerEmail.trim(),
        'customerName': customerName ?? cardholderName,
        'shippingAddress': shippingAddress ?? {'postal_code': postalCode},
        'successUrl': kIsWeb ? '${Uri.base.origin}/?status=success' : null,
        'cancelUrl': kIsWeb ? '${Uri.base.origin}/?status=cancelled' : null,
      };

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final checkoutUrl = data['checkoutUrl'] as String?;
        final sessionId = data['sessionId'] as String?;
        final orderId = data['orderId'] as String?;

        if (checkoutUrl != null) {
          // Open Stripe Checkout hosted session
          await launchHostedCheckout(checkoutUrl);

          // Return pending order placeholder for local display
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

          final pendingOrder = OrderModel(
            id: orderId ?? 'PENDING',
            userId: null,
            customerEmail: customerEmail.trim(),
            customerName: customerName ?? cardholderName,
            subtotal: subtotal,
            tax: tax,
            shipping: shipping,
            totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? totalAmount,
            status: 'pending',
            stripePaymentId: sessionId,
            shippingAddress: shippingAddress ?? {'postal_code': postalCode},
            items: orderItems,
            createdAt: DateTime.now(),
          );

          await _orderService.saveOrder(pendingOrder);

          return PaymentResult(
            isSuccess: true,
            isRedirect: true,
            checkoutUrl: checkoutUrl,
            paymentIntentId: sessionId,
            completedOrder: pendingOrder,
            isSimulated: false,
          );
        }
      }

      final errorJson = jsonDecode(response.body);
      final msg = errorJson['error'] ?? 'Stripe payment initialization failed';
      return PaymentResult(isSuccess: false, errorMessage: msg.toString());
    } catch (e) {
      debugPrint('StripePaymentService error: $e');
      return PaymentResult(
        isSuccess: false,
        errorMessage: 'Unable to connect to payments backend: $e',
      );
    }
  }
}
