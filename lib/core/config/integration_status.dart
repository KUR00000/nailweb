/// Lifecycle and readiness states for BYOK integrations.
enum IntegrationState {
  missingConfiguration,
  invalidConfiguration,
  connectedService,
  administrativeSetupRequired,
  verificationFailed,
  productionReady,
}

/// Comprehensive diagnostics descriptor for store integrations.
class IntegrationDiagnostics {
  final IntegrationState appModeState;
  final IntegrationState supabaseState;
  final IntegrationState googleOAuthState;
  final IntegrationState stripeState;
  final IntegrationState backendState;
  final List<String> issues;
  final List<String> instructions;

  const IntegrationDiagnostics({
    required this.appModeState,
    required this.supabaseState,
    required this.googleOAuthState,
    required this.stripeState,
    required this.backendState,
    required this.issues,
    required this.instructions,
  });

  bool get isProductionReady =>
      appModeState == IntegrationState.productionReady &&
      supabaseState == IntegrationState.productionReady &&
      stripeState == IntegrationState.productionReady &&
      backendState == IntegrationState.productionReady;

  bool get isDemoMode => appModeState == IntegrationState.connectedService;

  @override
  String toString() {
    return 'IntegrationDiagnostics('
        'appMode: $appModeState, '
        'supabase: $supabaseState, '
        'googleOAuth: $googleOAuthState, '
        'stripe: $stripeState, '
        'backend: $backendState, '
        'issues: ${issues.length})';
  }
}
