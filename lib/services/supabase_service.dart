import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/product.dart';
import 'integration_service.dart';

/// Service managing Supabase interactions, delegating cleanly to the BYOK Integration layer.
/// Preserves full backward-compatibility with all existing views and providers.
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final IntegrationService _integration = IntegrationService();

  bool get isInitialized => _integration.isSupabaseCloudInitialized;

  SupabaseClient? get client => _integration.supabaseClient;

  /// Initialize integrations
  Future<void> initialize() async {
    await _integration.initialize();
  }

  // --------------------------------------------------------------------------
  // AUTHENTICATION
  // --------------------------------------------------------------------------

  User? get currentUser => _integration.authService.currentUser;

  bool get isAuthenticated => _integration.authService.isAuthenticated;

  Stream<AuthState> get onAuthStateChange => _integration.authService.onAuthStateChange;

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) {
    return _integration.authService.signUpWithEmail(
      email: email,
      password: password,
      fullName: fullName,
    );
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _integration.authService.signInWithEmail(
      email: email,
      password: password,
    );
  }

  /// BYOK Google OAuth Sign-In via Supabase Auth
  Future<bool> signInWithGoogle() {
    return _integration.authService.signInWithGoogle();
  }

  Future<void> signInAsDemoVip() {
    return _integration.authService.signInAsDemoVip();
  }

  Future<void> signOut() {
    return _integration.authService.signOut();
  }

  Future<void> sendPasswordReset(String email) {
    return _integration.authService.sendPasswordReset(email);
  }

  // --------------------------------------------------------------------------
  // PRODUCTS DATABASE
  // --------------------------------------------------------------------------

  Future<List<Product>> fetchProducts() {
    return _integration.catalogService.fetchProducts();
  }

  // --------------------------------------------------------------------------
  // ORDERS DATABASE
  // --------------------------------------------------------------------------

  Future<bool> saveOrder(OrderModel order) {
    return _integration.orderService.saveOrder(order);
  }

  Future<List<OrderModel>> fetchOrders() {
    return _integration.orderService.fetchOrders();
  }
}
