import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import 'auth_service.dart';

/// In-memory authentication service for Atelier Demo mode.
class DemoAuthService implements AuthService {
  User? _currentUser;
  final _authStreamController = StreamController<AuthState>.broadcast();

  @override
  User? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;

  @override
  Stream<AuthState> get onAuthStateChange => _authStreamController.stream;

  @override
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final mockUser = User(
      id: 'demo-user-${DateTime.now().millisecondsSinceEpoch}',
      appMetadata: {},
      userMetadata: {'full_name': fullName ?? email.split('@').first},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
      email: email.trim(),
    );
    _currentUser = mockUser;
    final session = Session(
      accessToken: 'demo-access-token',
      tokenType: 'bearer',
      user: mockUser,
    );
    final response = AuthResponse(session: session, user: mockUser);
    _authStreamController.add(AuthState(AuthChangeEvent.signedIn, session));
    return response;
  }

  @override
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final mockUser = User(
      id: 'demo-user-vip',
      appMetadata: {},
      userMetadata: {'full_name': email.split('@').first},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
      email: email.trim(),
    );
    _currentUser = mockUser;
    final session = Session(
      accessToken: 'demo-access-token',
      tokenType: 'bearer',
      user: mockUser,
    );
    final response = AuthResponse(session: session, user: mockUser);
    _authStreamController.add(AuthState(AuthChangeEvent.signedIn, session));
    return response;
  }

  @override
  Future<bool> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final mockUser = User(
      id: 'demo-google-user',
      appMetadata: {'provider': 'google'},
      userMetadata: {
        'full_name': 'Google Atelier Guest',
        'avatar_url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      },
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
      email: 'google.guest@ivorynails.com',
    );
    _currentUser = mockUser;
    final session = Session(
      accessToken: 'demo-google-token',
      tokenType: 'bearer',
      user: mockUser,
    );
    _authStreamController.add(AuthState(AuthChangeEvent.signedIn, session));
    return true;
  }

  @override
  Future<void> signInAsDemoVip() async {
    await signInWithEmail(
      email: AppConstants.demoUserEmail,
      password: 'demoPassword123',
    );
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _authStreamController.add(const AuthState(AuthChangeEvent.signedOut, null));
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }
}
