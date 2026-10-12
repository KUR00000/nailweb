import 'package:flutter_test/flutter_test.dart';
import 'package:ivory_nails/core/config/app_config.dart';
import 'package:ivory_nails/models/cart_item.dart';
import 'package:ivory_nails/models/product.dart';
import 'package:ivory_nails/providers/cart_provider.dart';
import 'package:ivory_nails/services/integration_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('IntegrationService & Service Layer Tests', () {
    test('Initializes cleanly in Demo mode without external credentials', () async {
      final integration = IntegrationService();
      await integration.initialize(
        overrideConfig: const AppConfig(
          appMode: 'demo',
          supabaseUrl: '',
          supabasePublishableKey: '',
          stripePublishableKey: '',
          paymentsBackendUrl: '',
        ),
      );

      expect(integration.config.isDemo, isTrue);
      expect(integration.isSupabaseCloudInitialized, isFalse);
      expect(integration.paymentService.isDemo, isTrue);
      expect(integration.paymentService.canProcessRealPayments, isFalse);

      // Verify Demo catalog returns all 13 handcrafted items
      final products = await integration.catalogService.fetchProducts();
      expect(products.length, equals(13));
      expect(products.first.name, equals('Baby Blossom Polish'));
    });

    test('Demo checkout returns simulated order and does not contact Stripe', () async {
      final integration = IntegrationService();
      await integration.initialize(
        overrideConfig: const AppConfig(
          appMode: 'demo',
          supabaseUrl: '',
          supabasePublishableKey: '',
          stripePublishableKey: '',
          paymentsBackendUrl: '',
        ),
      );

      final demoProduct = Product.defaultProducts.first;
      final cartItem = CartItem(product: demoProduct, quantity: 2);

      final result = await integration.paymentService.processPayment(
        cartItems: [cartItem],
        subtotal: 29.00,
        tax: 2.32,
        shipping: 4.99,
        totalAmount: 36.31,
        cardholderName: 'Princess Test',
        cardNumber: '4242 4242 4242 4242',
        expiryDate: '12/28',
        cvc: '123',
        postalCode: '90210',
        customerEmail: 'princess.test@ivorynails.com',
      );

      expect(result.isSuccess, isTrue);
      expect(result.isSimulated, isTrue);
      expect(result.completedOrder, isNotNull);
      expect(result.completedOrder!.id.startsWith('IVORY-'), isTrue);
      expect(result.paymentIntentId!.startsWith('pi_3N'), isTrue);
    });

    test('Simulated test card ending in 0000 produces simulated decline', () async {
      final integration = IntegrationService();
      await integration.initialize(
        overrideConfig: const AppConfig(
          appMode: 'demo',
          supabaseUrl: '',
          supabasePublishableKey: '',
          stripePublishableKey: '',
          paymentsBackendUrl: '',
        ),
      );

      final result = await integration.paymentService.processPayment(
        cartItems: [CartItem(product: Product.defaultProducts.first, quantity: 1)],
        subtotal: 14.50,
        tax: 1.16,
        shipping: 4.99,
        totalAmount: 20.65,
        cardholderName: 'Decline Test',
        cardNumber: '4000 0000 0000 0000',
        expiryDate: '12/28',
        cvc: '123',
        postalCode: '90210',
        customerEmail: 'decline@ivorynails.com',
      );

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('declined'));
    });

    test('Production mode refuses incomplete payment configuration', () async {
      final integration = IntegrationService();
      // Configure production mode with missing backend endpoint
      await integration.initialize(
        overrideConfig: const AppConfig(
          appMode: 'production',
          supabaseUrl: '',
          supabasePublishableKey: '',
          stripePublishableKey: 'pk_test_51MyValidStripeKey4242',
          paymentsBackendUrl: '', // Missing backend!
        ),
      );

      // Must NOT enable real checkout when backend is missing
      expect(integration.paymentService.canProcessRealPayments, isFalse);
    });

    test('Google OAuth sign-in flow via AuthService', () async {
      final integration = IntegrationService();
      await integration.initialize(
        overrideConfig: const AppConfig(
          appMode: 'demo',
          supabaseUrl: '',
          supabasePublishableKey: '',
          stripePublishableKey: '',
          paymentsBackendUrl: '',
        ),
      );

      expect(integration.authService.isAuthenticated, isFalse);
      final success = await integration.authService.signInWithGoogle();
      expect(success, isTrue);
      expect(integration.authService.isAuthenticated, isTrue);
      expect(integration.authService.currentUser!.email, equals('google.guest@ivorynails.com'));

      await integration.authService.signOut();
      expect(integration.authService.isAuthenticated, isFalse);
    });

    test('CartProvider calculates taxes, discounts, and shipping accurately', () {
      final cart = CartProvider();
      final p1 = Product.defaultProducts[0]; // $14.50
      final p2 = Product.defaultProducts[1]; // $24.00

      cart.addToCart(p1, quantity: 1);
      expect(cart.rawSubtotal, equals(14.50));
      expect(cart.shipping, equals(4.99)); // Under $50
      expect(cart.tax, closeTo(1.16, 0.01));

      // Test promo coupon IVORY10 (10% off)
      final applied = cart.applyPromoCode('IVORY10');
      expect(applied, isTrue);
      expect(cart.discountAmount, closeTo(1.45, 0.01));
      expect(cart.subtotal, closeTo(13.05, 0.01));

      // Add more items to cross $50 threshold
      cart.addToCart(p2, quantity: 2); // +$48.00 -> rawSubtotal = $62.50
      expect(cart.shipping, equals(0.00)); // Free shipping!
    });
  });
}
