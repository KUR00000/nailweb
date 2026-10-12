import 'package:flutter_test/flutter_test.dart';
import 'package:ivory_nails/core/config/app_config.dart';
import 'package:ivory_nails/core/config/integration_status.dart';

void main() {
  group('AppConfig Tests', () {
    test('Default configuration defaults to Demo mode', () {
      final config = AppConfig.fromEnvironment();
      expect(config.isDemo, isTrue);
      expect(config.isProduction, isFalse);

      final diag = config.evaluateDiagnostics();
      expect(diag.appModeState, equals(IntegrationState.connectedService));
      expect(diag.isDemoMode, isTrue);
    });

    test('Loads valid BYOK production configuration from JSON map', () {
      final json = {
        'APP_MODE': 'production',
        'SUPABASE_URL': 'https://myatelier.supabase.co',
        'SUPABASE_PUBLISHABLE_KEY':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.validAnonKeyForIvoryNailsStore',
        'GOOGLE_CLIENT_ID': '1234567890-atelier.apps.googleusercontent.com',
        'STRIPE_PUBLISHABLE_KEY': 'pk_test_51IvoryNailsLiveKey987654321',
        'PAYMENTS_BACKEND_URL': 'https://api.ivorynails.com/payments',
      };

      final config = AppConfig.fromJson(json);
      expect(config.isProduction, isTrue);
      expect(config.hasValidSupabase, isTrue);
      expect(config.hasValidStripePublishableKey, isTrue);
      expect(config.hasValidPaymentsBackend, isTrue);
      expect(config.hasValidGoogleOAuth, isTrue);

      final diag = config.evaluateDiagnostics();
      expect(diag.appModeState, equals(IntegrationState.productionReady));
      expect(diag.supabaseState, equals(IntegrationState.productionReady));
      expect(diag.stripeState, equals(IntegrationState.productionReady));
      expect(diag.backendState, equals(IntegrationState.productionReady));
      expect(diag.issues, isEmpty);
    });

    test('Production mode flags unreplaced placeholders as invalid configuration', () {
      final json = {
        'APP_MODE': 'production',
        'SUPABASE_URL': 'https://YOUR_PROJECT.supabase.co',
        'SUPABASE_PUBLISHABLE_KEY': 'YOUR_SUPABASE_PUBLISHABLE_KEY',
        'STRIPE_PUBLISHABLE_KEY': 'pk_test_YOUR_KEY',
        'PAYMENTS_BACKEND_URL': 'YOUR_BACKEND_ENDPOINT',
      };

      final config = AppConfig.fromJson(json);
      expect(config.isProduction, isTrue);
      expect(config.hasValidSupabase, isFalse);
      expect(config.hasValidStripePublishableKey, isFalse);
      expect(config.hasValidPaymentsBackend, isFalse);

      final diag = config.evaluateDiagnostics();
      expect(diag.isProductionReady, isFalse);
      expect(diag.supabaseState, equals(IntegrationState.invalidConfiguration));
      expect(diag.stripeState, equals(IntegrationState.invalidConfiguration));
      expect(diag.backendState, equals(IntegrationState.invalidConfiguration));
      expect(diag.issues.length, greaterThanOrEqualTo(3));
    });

    test('toRedactedMap strictly masks private credential fragments', () {
      final json = {
        'APP_MODE': 'production',
        'SUPABASE_URL': 'https://myatelier.supabase.co',
        'SUPABASE_PUBLISHABLE_KEY': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.superSecretKeyAtelier',
        'STRIPE_PUBLISHABLE_KEY': 'pk_test_51SecretStripeKey4242',
      };

      final config = AppConfig.fromJson(json);
      final redacted = config.toRedactedMap();

      expect(redacted['APP_MODE'], equals('production'));
      expect(redacted['SUPABASE_PUBLISHABLE_KEY']!.contains('superSecretKey'), isFalse);
      expect(redacted['STRIPE_PUBLISHABLE_KEY']!.contains('SecretStripe'), isFalse);
    });
  });
}
