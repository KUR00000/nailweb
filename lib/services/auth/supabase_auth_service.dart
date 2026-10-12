import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

/// Production authentication service connected to customer-owned Supabase project.
class SupabaseAuthService implements AuthService {
  final SupabaseClient _client;

  SupabaseAuthService(this._client);

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  bool get isAuthenticated => currentUser != null;

  @override
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  @override
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName ?? email.split('@').first},
      );
      return response;
    } catch (e) {
      debugPrint('Supabase signUp error: $e');
      rethrow;
    }
  }

  @override
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response;
    } catch (e) {
      debugPrint('Supabase signIn error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> signInWithGoogle() async {
    try {
      // In web browser, determine the current origin for safe redirect validation
      String? redirectUrl;
      if (kIsWeb) {
        redirectUrl = Uri.base.origin;
      }

      final success = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        authScreenLaunchMode: LaunchMode.platformDefault,
      );
      return success;
    } catch (e) {
      debugPrint('Supabase Google OAuth error: $e');
      rethrow;
    }
  }

  @override
  Future<void> signInAsDemoVip() async {
    // In production mode with live Supabase, attempt login or sign up
    try {
      await signInWithEmail(
        email: 'princess.vip@ivorynails.com',
        password: 'VipPrincessAtelier2026!',
      );
    } catch (_) {
      // If user doesn't exist, try creating it
      await signUpWithEmail(
        email: 'princess.vip@ivorynails.com',
        password: 'VipPrincessAtelier2026!',
        fullName: 'Princess Ivory VIP',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('Supabase signOut error: $e');
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(email.trim());
  }
}
