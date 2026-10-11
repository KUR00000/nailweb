import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';
import '../models/order.dart';
import '../models/product.dart';

/// Service managing Supabase Authentication and Database interactions.
/// Includes an integrated Atelier Demo fallback so the app works seamlessly
/// even before live Supabase credentials are configured.
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // In-memory mock storage for zero-config demonstration mode
  final List<OrderModel> _mockOrders = [];
  User? _mockCurrentUser;
  final _mockAuthStreamController = StreamController<AuthState>.broadcast();

  SupabaseClient? get client {
    if (_isInitialized) {
      try {
        return Supabase.instance.client;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Initialize Supabase client
  Future<void> initialize() async {
    if (AppConstants.isUsingDemoSupabase) {
      debugPrint('✨ Ivory Nails: Operating in Atelier Demo mode (Local Supabase Mock)');
      _isInitialized = false;
      return;
    }

    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey, // ignore: deprecated_member_use
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      _isInitialized = true;
      debugPrint('✨ Ivory Nails: Successfully connected to Supabase Cloud');
    } catch (e) {
      debugPrint('⚠️ Supabase initialization warning: $e. Using local demo fallback.');
      _isInitialized = false;
    }
  }

  // --------------------------------------------------------------------------
  // AUTHENTICATION
  // --------------------------------------------------------------------------

  /// Current user or null
  User? get currentUser {
    if (_isInitialized && client != null) {
      return client!.auth.currentUser;
    }
    return _mockCurrentUser;
  }

  /// Check if user is logged in
  bool get isAuthenticated => currentUser != null;

  /// Stream of authentication state changes
  Stream<AuthState> get onAuthStateChange {
    if (_isInitialized && client != null) {
      return client!.auth.onAuthStateChange;
    }
    return _mockAuthStreamController.stream;
  }

  /// Sign Up with Email and Password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    if (_isInitialized && client != null) {
      try {
        final response = await client!.auth.signUp(
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

    // Local Demo Auth Simulation
    await Future.delayed(const Duration(milliseconds: 600));
    final mockUser = User(
      id: 'demo-user-${DateTime.now().millisecondsSinceEpoch}',
      appMetadata: {},
      userMetadata: {'full_name': fullName ?? email.split('@').first},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
      email: email.trim(),
    );
    _mockCurrentUser = mockUser;
    final session = Session(
      accessToken: 'demo-access-token',
      tokenType: 'bearer',
      user: mockUser,
    );
    final response = AuthResponse(session: session, user: mockUser);
    _mockAuthStreamController.add(AuthState(AuthChangeEvent.signedIn, session));
    return response;
  }

  /// Sign In with Email and Password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (_isInitialized && client != null) {
      try {
        final response = await client!.auth.signInWithPassword(
          email: email.trim(),
          password: password,
        );
        return response;
      } catch (e) {
        debugPrint('Supabase signIn error: $e');
        rethrow;
      }
    }

    // Local Demo Auth Simulation
    await Future.delayed(const Duration(milliseconds: 600));
    final mockUser = User(
      id: 'demo-user-vip',
      appMetadata: {},
      userMetadata: {'full_name': email.split('@').first},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
      email: email.trim(),
    );
    _mockCurrentUser = mockUser;
    final session = Session(
      accessToken: 'demo-access-token',
      tokenType: 'bearer',
      user: mockUser,
    );
    final response = AuthResponse(session: session, user: mockUser);
    _mockAuthStreamController.add(AuthState(AuthChangeEvent.signedIn, session));
    return response;
  }

  /// Instant 1-Click VIP Demo Login
  Future<void> signInAsDemoVip() async {
    await signInWithEmail(
      email: AppConstants.demoUserEmail,
      password: 'demoPassword123',
    );
  }

  /// Sign Out
  Future<void> signOut() async {
    if (_isInitialized && client != null) {
      try {
        await client!.auth.signOut();
      } catch (e) {
        debugPrint('Supabase signOut error: $e');
      }
    }
    _mockCurrentUser = null;
    _mockAuthStreamController.add(const AuthState(AuthChangeEvent.signedOut, null));
  }

  /// Send Password Reset Link
  Future<void> sendPasswordReset(String email) async {
    if (_isInitialized && client != null) {
      await client!.auth.resetPasswordForEmail(email.trim());
      return;
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // --------------------------------------------------------------------------
  // PRODUCTS DATABASE
  // --------------------------------------------------------------------------

  /// Fetch products from Supabase 'products' table, with automatic fallback
  Future<List<Product>> fetchProducts() async {
    if (_isInitialized && client != null) {
      try {
        final response = await client!
            .from('products')
            .select()
            .order('price', ascending: true);

        final items = (response as List<dynamic>)
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();

        if (items.isNotEmpty) {
          return items;
        }
      } catch (e) {
        debugPrint('Error fetching products from Supabase: $e');
      }
    }

    // Fallback to the 13 curated luxury items
    return Product.defaultProducts;
  }

  // --------------------------------------------------------------------------
  // ORDERS DATABASE
  // --------------------------------------------------------------------------

  /// Persist a newly paid order into Supabase
  Future<bool> saveOrder(OrderModel order) async {
    // Always keep a local copy for immediate UI responsiveness
    _mockOrders.insert(0, order);

    if (_isInitialized && client != null) {
      try {
        // 1. Insert into orders table
        await client!.from('orders').insert({
          'id': order.id,
          'user_id': currentUser?.id,
          'customer_email': order.customerEmail,
          'customer_name': order.customerName,
          'subtotal': order.subtotal,
          'tax': order.tax,
          'shipping': order.shipping,
          'total_amount': order.totalAmount,
          'status': order.status,
          'stripe_payment_id': order.stripePaymentId,
          'shipping_address': order.shippingAddress,
          'created_at': order.createdAt.toIso8601String(),
        });

        // 2. Insert items into order_items table
        final itemsPayload = order.items.map((item) => {
              'order_id': order.id,
              'product_id': item.productId,
              'product_name': item.productName,
              'quantity': item.quantity,
              'unit_price': item.unitPrice,
              'total_price': item.totalPrice,
            }).toList();

        await client!.from('order_items').insert(itemsPayload);
        return true;
      } catch (e) {
        debugPrint('Failed to save order to Supabase: $e');
        return false;
      }
    }

    return true;
  }

  /// Retrieve past orders for current user
  Future<List<OrderModel>> fetchOrders() async {
    if (_isInitialized && client != null && currentUser != null) {
      try {
        final response = await client!
            .from('orders')
            .select('*, order_items(*)')
            .eq('user_id', currentUser!.id)
            .order('created_at', ascending: false);

        final list = (response as List<dynamic>).map((row) {
          final itemsList = (row['order_items'] as List<dynamic>?)
                  ?.map((it) => OrderItemModel.fromJson(it))
                  .toList() ??
              [];
          return OrderModel(
            id: row['id'],
            userId: row['user_id'],
            customerEmail: row['customer_email'] ?? '',
            customerName: row['customer_name'] ?? '',
            subtotal: (row['subtotal'] as num?)?.toDouble() ?? 0.0,
            tax: (row['tax'] as num?)?.toDouble() ?? 0.0,
            shipping: (row['shipping'] as num?)?.toDouble() ?? 0.0,
            totalAmount: (row['total_amount'] as num?)?.toDouble() ?? 0.0,
            status: row['status'] ?? 'paid',
            stripePaymentId: row['stripe_payment_id'],
            shippingAddress: row['shipping_address'] as Map<String, dynamic>?,
            items: itemsList,
            createdAt: row['created_at'] != null
                ? DateTime.tryParse(row['created_at']) ?? DateTime.now()
                : DateTime.now(),
          );
        }).toList();

        if (list.isNotEmpty) {
          return list;
        }
      } catch (e) {
        debugPrint('Error fetching orders from Supabase: $e');
      }
    }

    return List.unmodifiable(_mockOrders);
  }
}
