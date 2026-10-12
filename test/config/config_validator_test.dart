import 'package:flutter_test/flutter_test.dart';
import 'package:ivory_nails/core/config/config_validator.dart';

void main() {
  group('ConfigValidator Tests', () {
    test('isValidUrl accepts valid HTTPS and HTTP URLs', () {
      expect(ConfigValidator.isValidUrl('https://myproject.supabase.co'), isTrue);
      expect(ConfigValidator.isValidUrl('http://localhost:4242'), isTrue);
      expect(ConfigValidator.isValidUrl('https://api.ivorynails.com/v1'), isTrue);
    });

    test('isValidUrl rejects invalid or placeholder URLs', () {
      expect(ConfigValidator.isValidUrl(''), isFalse);
      expect(ConfigValidator.isValidUrl('not-a-url'), isFalse);
      expect(ConfigValidator.isValidUrl('ftp://example.com'), isFalse);
      expect(ConfigValidator.isValidUrl('https://YOUR_PROJECT.supabase.co'), isFalse);
      expect(ConfigValidator.isValidUrl('YOUR_BACKEND_ENDPOINT'), isFalse);
    });

    test('isValidStripePublishableKey accepts pk_test_ and pk_live_', () {
      expect(
        ConfigValidator.isValidStripePublishableKey('pk_test_51IvoryNailsDemo42'),
        isTrue,
      );
      expect(
        ConfigValidator.isValidStripePublishableKey('pk_live_51IvoryNailsLive42'),
        isTrue,
      );
    });

    test('isValidStripePublishableKey rejects secret keys and placeholders', () {
      // Must NEVER accept sk_ secret keys as publishable keys!
      expect(
        ConfigValidator.isValidStripePublishableKey('sk_test_secretKey12345'),
        isFalse,
      );
      expect(
        ConfigValidator.isValidStripePublishableKey('sk_live_secretKey12345'),
        isFalse,
      );
      expect(
        ConfigValidator.isValidStripePublishableKey('pk_test_YOUR_KEY'),
        isFalse,
      );
      expect(ConfigValidator.isValidStripePublishableKey(''), isFalse);
    });

    test('isValidSupabaseKey validates length and rejects placeholders', () {
      expect(
        ConfigValidator.isValidSupabaseKey(
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.realAnonKeyForAtelierNailsStore',
        ),
        isTrue,
      );
      expect(
        ConfigValidator.isValidSupabaseKey('YOUR_SUPABASE_PUBLISHABLE_KEY'),
        isFalse,
      );
      expect(ConfigValidator.isValidSupabaseKey('short'), isFalse);
      expect(ConfigValidator.isValidSupabaseKey(''), isFalse);
    });

    test('redact masks sensitive credentials without exposing them', () {
      final redacted = ConfigValidator.redact('pk_test_51IvoryNailsDemo4242');
      expect(redacted.startsWith('pk_test'), isTrue);
      expect(redacted.contains('***'), isTrue);
      expect(redacted.contains('IvoryNails'), isFalse); // Sensitive middle string redacted
      expect(ConfigValidator.redact(''), equals('(not set)'));
      expect(ConfigValidator.redact(null), equals('(not set)'));
    });
  });
}
