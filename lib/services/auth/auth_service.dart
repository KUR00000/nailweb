import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract authentication service for Ivory Nails Atelier.
abstract class AuthService {
  User? get currentUser;
  bool get isAuthenticated;
  Stream<AuthState> get onAuthStateChange;

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  });

  /// BYOK Google OAuth Sign-In via Supabase Auth
  Future<bool> signInWithGoogle();

  /// 1-Click Demo VIP Sign-In
  Future<void> signInAsDemoVip();

  Future<void> signOut();

  Future<void> sendPasswordReset(String email);
}
