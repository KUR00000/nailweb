/// Application-wide constants, backend configurations, and branding values.
class AppConstants {
  static const String appName = 'Ivory Nails';
  static const String appTagline = 'Luxury Press-Ons & Polishes';
  static const String brandSubhead = 'Atelier de Manucure • Haute Élégance';

  // --------------------------------------------------------------------------
  // SUPABASE CONFIGURATION
  // Can be overridden via --dart-define=SUPABASE_URL=... and SUPABASE_ANON_KEY=...
  // --------------------------------------------------------------------------
  static const String defaultSupabaseUrl = 'https://demo-ivorynails.supabase.co';
  static const String defaultSupabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.demo-anon-key-ivory-nails';

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: defaultSupabaseUrl,
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: defaultSupabaseAnonKey,
  );

  /// Check whether live Supabase credentials are configured or if running in local atelier demo mode
  static bool get isUsingDemoSupabase =>
      supabaseUrl == defaultSupabaseUrl || supabaseAnonKey == defaultSupabaseAnonKey;

  // --------------------------------------------------------------------------
  // STRIPE CONFIGURATION
  // Can be overridden via --dart-define=STRIPE_PUBLISHABLE_KEY=...
  // --------------------------------------------------------------------------
  static const String defaultStripePublishableKey =
      'pk_test_51IvoryNailsDemoPublishableKey424242424242424242';

  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: defaultStripePublishableKey,
  );

  // --------------------------------------------------------------------------
  // STORE COMMERCE RULES
  // --------------------------------------------------------------------------
  static const double taxRate = 0.08; // 8% sales tax
  static const double freeShippingThreshold = 50.00; // Free shipping over $50
  static const double standardShippingFee = 4.99; // Standard shipping

  // Demo user preset
  static const String demoUserEmail = 'princess.vip@ivorynails.com';
  static const String demoUserName = 'Princess Ivory VIP';
}
