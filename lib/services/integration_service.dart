import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/app_config.dart';
import '../core/config/integration_status.dart';
import 'auth/auth_service.dart';
import 'auth/demo_auth_service.dart';
import 'auth/supabase_auth_service.dart';
import 'catalog/catalog_service.dart';
import 'catalog/demo_catalog_service.dart';
import 'catalog/supabase_catalog_service.dart';
import 'order/demo_order_service.dart';
import 'order/order_service.dart';
import 'order/supabase_order_service.dart';
import 'payment/demo_payment_service.dart';
import 'payment/payment_service.dart';
import 'payment/stripe_payment_service.dart';

/// Central BYOK Integration Service orchestrating initialization,
/// configuration validation, and service selection.
class IntegrationService {
  static final IntegrationService _instance = IntegrationService._internal();
  factory IntegrationService() => _instance;
  IntegrationService._internal();

  AppConfig _config = AppConfig.fromEnvironment();
  AppConfig get config => _config;

  late IntegrationDiagnostics _diagnostics;
  IntegrationDiagnostics get diagnostics => _diagnostics;

  bool _isSupabaseCloudInitialized = false;
  bool get isSupabaseCloudInitialized => _isSupabaseCloudInitialized;

  late AuthService authService;
  late CatalogService catalogService;
  late OrderService orderService;
  late PaymentService paymentService;

  SupabaseClient? get supabaseClient {
    if (_isSupabaseCloudInitialized) {
      try {
        return Supabase.instance.client;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Initialize all store integrations with BYOK configuration.
  Future<void> initialize({AppConfig? overrideConfig}) async {
    _config = overrideConfig ?? AppConfig.fromEnvironment();
    _diagnostics = _config.evaluateDiagnostics();

    // 1. Initialize Supabase if valid credentials provided
    if (_config.hasValidSupabase) {
      try {
        await Supabase.initialize(
          url: _config.supabaseUrl,
          anonKey: _config.supabasePublishableKey, // ignore: deprecated_member_use
          authOptions: const FlutterAuthClientOptions(
            authFlowType: AuthFlowType.pkce,
          ),
        );
        _isSupabaseCloudInitialized = true;
        debugPrint('✨ Ivory Nails BYOK: Connected to Supabase Cloud (${_config.supabaseUrl})');
      } catch (e) {
        debugPrint('⚠️ Supabase Cloud initialization warning: $e');
        _isSupabaseCloudInitialized = false;
      }
    } else {
      _isSupabaseCloudInitialized = false;
    }

    // 2. Select Services based on mode and initialization state
    if (_isSupabaseCloudInitialized && supabaseClient != null) {
      authService = SupabaseAuthService(supabaseClient!);
      catalogService = SupabaseCatalogService(supabaseClient!);
      orderService = SupabaseOrderService(supabaseClient!);
    } else {
      final demoAuth = DemoAuthService();
      final demoOrder = DemoOrderService();
      authService = demoAuth;
      catalogService = DemoCatalogService();
      orderService = demoOrder;
    }

    // 3. Select Payment Service
    if (_config.isProduction && _config.hasValidStripePublishableKey && _config.hasValidPaymentsBackend) {
      paymentService = StripePaymentService(_config, orderService);
      debugPrint('✨ Ivory Nails BYOK: Stripe Payments active via backend (${_config.paymentsBackendUrl})');
    } else {
      paymentService = DemoPaymentService(orderService);
      if (_config.isProduction) {
        debugPrint(
          '⚠️ Ivory Nails BYOK: Production mode selected but Stripe backend is incomplete. '
          'Simulated payments are disabled in production.',
        );
      } else {
        debugPrint('✨ Ivory Nails BYOK: Operating in Atelier Demo mode (Simulated Checkout active)');
      }
    }

    _logStartupDiagnostics();
  }

  void _logStartupDiagnostics() {
    debugPrint('----------------------------------------------------');
    debugPrint('Ivory Nails Atelier — BYOK Integration Diagnostics:');
    final redacted = _config.toRedactedMap();
    redacted.forEach((key, value) {
      debugPrint('  $key: $value');
    });
    if (_diagnostics.issues.isNotEmpty) {
      debugPrint('  Diagnostics issues:');
      for (final issue in _diagnostics.issues) {
        debugPrint('    • $issue');
      }
    }
    debugPrint('----------------------------------------------------');
  }
}
