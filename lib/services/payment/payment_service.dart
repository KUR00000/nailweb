import '../../models/cart_item.dart';
import '../../models/order.dart';

/// Container for the result of a payment request.
class PaymentResult {
  final bool isSuccess;
  final bool isRedirect;
  final String? checkoutUrl;
  final String? paymentIntentId;
  final String? errorMessage;
  final OrderModel? completedOrder;
  final bool isSimulated;

  const PaymentResult({
    required this.isSuccess,
    this.isRedirect = false,
    this.checkoutUrl,
    this.paymentIntentId,
    this.errorMessage,
    this.completedOrder,
    this.isSimulated = false,
  });
}

/// Abstract payment service interface.
abstract class PaymentService {
  bool get canProcessRealPayments;
  bool get isDemo;

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
  });
}
