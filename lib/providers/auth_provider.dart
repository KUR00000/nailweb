import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

/// State management provider for Supabase User Authentication.
class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  User? get currentUser => _supabaseService.currentUser;
  bool get isAuthenticated => _supabaseService.isAuthenticated;

  String get userEmail => currentUser?.email ?? 'guest@atelier.com';
  String get userName {
    final meta = currentUser?.userMetadata;
    if (meta != null && meta['full_name'] != null && (meta['full_name'] as String).isNotEmpty) {
      return meta['full_name'];
    }
    return currentUser?.email?.split('@').first ?? 'Guest';
  }

  bool get isVip =>
      userName.toLowerCase().contains('vip') ||
      userEmail.toLowerCase().contains('vip') ||
      (currentUser?.userMetadata?['role'] == 'vip');

  AuthProvider() {
    _supabaseService.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Sign In with Email
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.signInWithEmail(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Sign Up with Email
  Future<bool> signUp(String email, String password, {String? fullName}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// One-click Demo VIP Mode
  Future<void> signInAsDemoVip() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.signInAsDemoVip();
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    await _supabaseService.signOut();
    _isLoading = false;
    notifyListeners();
  }

  /// Password Reset
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.sendPasswordReset(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _cleanErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  String _cleanErrorMessage(dynamic error) {
    if (error is AuthException) {
      return error.message;
    }
    final str = error.toString();
    if (str.contains('Exception:')) {
      return str.replaceAll('Exception:', '').trim();
    }
    return str;
  }
}
