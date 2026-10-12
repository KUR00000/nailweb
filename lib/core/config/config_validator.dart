/// Validator for BYOK public configuration values.
/// Ensures security, key formats, and sanitized diagnostic reporting without credential leakage.
class ConfigValidator {
  static const List<String> _placeholderMarkers = [
    'YOUR_PROJECT',
    'YOUR_KEY',
    'YOUR_SUPABASE',
    'YOUR_GOOGLE',
    'YOUR_BACKEND',
    'placeholder',
    'example',
  ];

  /// Safely masks sensitive keys for log and diagnostic output.
  /// Example: "pk_test_51IvoryNailsDemo" -> "pk_test_***Demo"
  static String redact(String? value) {
    if (value == null || value.trim().isEmpty) return '(not set)';
    final clean = value.trim();
    if (clean.length <= 8) return '********';
    final prefix = clean.substring(0, 7);
    final suffix = clean.substring(clean.length - 4);
    return '$prefix***$suffix';
  }

  /// Check whether a value is an unconfigured template placeholder.
  static bool isPlaceholder(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final lower = value.toLowerCase();
    return _placeholderMarkers.any((marker) => lower.contains(marker.toLowerCase()));
  }

  /// Validate an HTTP / HTTPS URL format.
  static bool isValidUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    if (isPlaceholder(url)) return false;
    try {
      final uri = Uri.parse(url.trim());
      return uri.hasScheme && (uri.scheme == 'https' || uri.scheme == 'http') && uri.hasAuthority;
    } catch (_) {
      return false;
    }
  }

  /// Validate Stripe publishable key format (must start with pk_test_ or pk_live_).
  static bool isValidStripePublishableKey(String? key) {
    if (key == null || key.trim().isEmpty) return false;
    if (isPlaceholder(key)) return false;
    final clean = key.trim();
    return clean.startsWith('pk_test_') || clean.startsWith('pk_live_');
  }

  /// Validate Supabase publishable / anon key format.
  static bool isValidSupabaseKey(String? key) {
    if (key == null || key.trim().isEmpty) return false;
    if (isPlaceholder(key)) return false;
    final clean = key.trim();
    // Supabase keys are standard JWT tokens or at least 20 chars
    return clean.length >= 20;
  }

  /// Validate Google Client ID.
  static bool isValidGoogleClientId(String? clientId) {
    if (clientId == null || clientId.trim().isEmpty) return false;
    if (isPlaceholder(clientId)) return false;
    return clientId.contains('.apps.googleusercontent.com') || clientId.length > 10;
  }
}
