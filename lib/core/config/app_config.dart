import 'config_validator.dart';
import 'integration_status.dart';

/// Central model representing BYOK public configuration for Ivory Nails Atelier.
class AppConfig {
  final String appMode;
  final String supabaseUrl;
  final String supabasePublishableKey;
  final String? googleClientId;
  final String stripePublishableKey;
  final String paymentsBackendUrl;

  const AppConfig({
    required this.appMode,
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    this.googleClientId,
    required this.stripePublishableKey,
    required this.paymentsBackendUrl,
  });

  bool get isProduction => appMode.trim().toLowerCase() == 'production';
  bool get isDemo => !isProduction;

  bool get hasValidSupabase =>
      ConfigValidator.isValidUrl(supabaseUrl) &&
      ConfigValidator.isValidSupabaseKey(supabasePublishableKey);

  bool get hasValidStripePublishableKey =>
      ConfigValidator.isValidStripePublishableKey(stripePublishableKey);

  bool get hasValidPaymentsBackend =>
      ConfigValidator.isValidUrl(paymentsBackendUrl);

  bool get hasValidGoogleOAuth =>
      ConfigValidator.isValidGoogleClientId(googleClientId);

  /// Load configuration from compile-time / dart-define environment variables
  /// (which are injected directly via `flutter run --dart-define-from-file=.env.json`
  /// or `--dart-define=...`).
  factory AppConfig.fromEnvironment() {
    const mode = String.fromEnvironment('APP_MODE', defaultValue: 'demo');
    const supaUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const supaPub = String.fromEnvironment(
      'SUPABASE_PUBLISHABLE_KEY',
      defaultValue: String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: ''),
    );
    const googleId = String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: '');
    const stripePub = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY', defaultValue: '');
    const backendUrl = String.fromEnvironment('PAYMENTS_BACKEND_URL', defaultValue: '');

    return AppConfig(
      appMode: mode,
      supabaseUrl: supaUrl,
      supabasePublishableKey: supaPub,
      googleClientId: googleId.isNotEmpty ? googleId : null,
      stripePublishableKey: stripePub,
      paymentsBackendUrl: backendUrl,
    );
  }

  /// Construct from a JSON map (e.g. for unit testing or json decoding)
  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final supaPub = json['SUPABASE_PUBLISHABLE_KEY'] ?? json['SUPABASE_ANON_KEY'] ?? '';
    final googleId = json['GOOGLE_CLIENT_ID']?.toString();

    return AppConfig(
      appMode: (json['APP_MODE'] ?? 'demo').toString(),
      supabaseUrl: (json['SUPABASE_URL'] ?? '').toString(),
      supabasePublishableKey: supaPub.toString(),
      googleClientId: (googleId != null && googleId.isNotEmpty) ? googleId : null,
      stripePublishableKey: (json['STRIPE_PUBLISHABLE_KEY'] ?? '').toString(),
      paymentsBackendUrl: (json['PAYMENTS_BACKEND_URL'] ?? '').toString(),
    );
  }

  /// Evaluate the configuration and generate detailed diagnostics.
  IntegrationDiagnostics evaluateDiagnostics() {
    final issues = <String>[];
    final instructions = <String>[];

    // 1. App Mode
    IntegrationState modeState;
    if (isDemo) {
      modeState = IntegrationState.connectedService; // Demo mode active
    } else {
      modeState = IntegrationState.productionReady;
    }

    // 2. Supabase
    IntegrationState supaState;
    if (supabaseUrl.isEmpty && supabasePublishableKey.isEmpty) {
      supaState = IntegrationState.missingConfiguration;
      if (isProduction) {
        issues.add('SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY are missing.');
        instructions.add(
          'Provide your Supabase Project URL and Publishable Anon Key in .env.json.',
        );
      }
    } else if (!ConfigValidator.isValidUrl(supabaseUrl)) {
      supaState = IntegrationState.invalidConfiguration;
      issues.add('SUPABASE_URL is invalid or is an unreplaced placeholder.');
      instructions.add('Set SUPABASE_URL to a valid https://YOUR_PROJECT.supabase.co URL.');
    } else if (!ConfigValidator.isValidSupabaseKey(supabasePublishableKey)) {
      supaState = IntegrationState.invalidConfiguration;
      issues.add('SUPABASE_PUBLISHABLE_KEY is invalid or placeholder.');
      instructions.add('Set SUPABASE_PUBLISHABLE_KEY to your project anon key from API settings.');
    } else {
      supaState = IntegrationState.productionReady;
    }

    // 3. Google OAuth
    IntegrationState googleState;
    if (googleClientId == null || googleClientId!.isEmpty) {
      googleState = IntegrationState.missingConfiguration;
      // Optional for app operation, but noted
    } else if (!ConfigValidator.isValidGoogleClientId(googleClientId)) {
      googleState = IntegrationState.invalidConfiguration;
      issues.add('GOOGLE_CLIENT_ID is invalid or placeholder.');
      instructions.add(
        'Configure Google OAuth provider in Supabase Auth and supply your Web Client ID.',
      );
    } else {
      googleState = IntegrationState.productionReady;
    }

    // 4. Stripe
    IntegrationState stripeState;
    if (stripePublishableKey.isEmpty) {
      stripeState = IntegrationState.missingConfiguration;
      if (isProduction) {
        issues.add('STRIPE_PUBLISHABLE_KEY is missing.');
        instructions.add('Set STRIPE_PUBLISHABLE_KEY to your pk_test_... or pk_live_... key.');
      }
    } else if (!ConfigValidator.isValidStripePublishableKey(stripePublishableKey)) {
      stripeState = IntegrationState.invalidConfiguration;
      issues.add('STRIPE_PUBLISHABLE_KEY must begin with pk_test_ or pk_live_.');
      instructions.add('Verify your Stripe publishable key format from dashboard.stripe.com.');
    } else {
      stripeState = IntegrationState.productionReady;
    }

    // 5. Backend
    IntegrationState backendState;
    if (paymentsBackendUrl.isEmpty) {
      backendState = IntegrationState.missingConfiguration;
      if (isProduction) {
        issues.add('PAYMENTS_BACKEND_URL is missing.');
        instructions.add(
          'Provide the URL of your trusted backend or Supabase Edge Functions endpoint in .env.json.',
        );
      }
    } else if (!ConfigValidator.isValidUrl(paymentsBackendUrl)) {
      backendState = IntegrationState.invalidConfiguration;
      issues.add('PAYMENTS_BACKEND_URL is invalid or is an unreplaced placeholder.');
      instructions.add('Set PAYMENTS_BACKEND_URL to your deployed backend or Edge Function URL.');
    } else {
      backendState = IntegrationState.productionReady;
    }

    return IntegrationDiagnostics(
      appModeState: modeState,
      supabaseState: supaState,
      googleOAuthState: googleState,
      stripeState: stripeState,
      backendState: backendState,
      issues: issues,
      instructions: instructions,
    );
  }

  /// Sanitized string representation without credential exposure.
  Map<String, String> toRedactedMap() {
    return {
      'APP_MODE': appMode,
      'SUPABASE_URL': supabaseUrl.isNotEmpty ? supabaseUrl : '(empty)',
      'SUPABASE_PUBLISHABLE_KEY': ConfigValidator.redact(supabasePublishableKey),
      'GOOGLE_CLIENT_ID': ConfigValidator.redact(googleClientId),
      'STRIPE_PUBLISHABLE_KEY': ConfigValidator.redact(stripePublishableKey),
      'PAYMENTS_BACKEND_URL': paymentsBackendUrl.isNotEmpty ? paymentsBackendUrl : '(empty)',
    };
  }
}
