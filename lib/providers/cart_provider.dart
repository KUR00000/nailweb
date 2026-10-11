import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

/// Provider managing the customer's luxury shopping bag.
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  String? _appliedPromoCode;
  double _discountPercentage = 0.0;

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => _items.isEmpty;

  String? get appliedPromoCode => _appliedPromoCode;
  double get discountPercentage => _discountPercentage;

  /// Check if a product is already in the bag
  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  /// Get the current quantity of a specific product in bag
  int getQuantity(String productId) {
    final match = _items.where((item) => item.product.id == productId);
    return match.isNotEmpty ? match.first.quantity : 0;
  }

  /// Subtotal before discounts, taxes, and shipping
  double get rawSubtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Discount amount if promo applied
  double get discountAmount => rawSubtotal * _discountPercentage;

  /// Net Subtotal
  double get subtotal => rawSubtotal - discountAmount;

  /// Estimated Sales Tax (8%)
  double get tax => subtotal * AppConstants.taxRate;

  /// Shipping Calculation
  double get shipping {
    if (isEmpty || subtotal >= AppConstants.freeShippingThreshold) {
      return 0.0;
    }
    return AppConstants.standardShippingFee;
  }

  /// Progress towards Free Shipping ($50 threshold)
  double get freeShippingProgress {
    if (subtotal >= AppConstants.freeShippingThreshold) return 1.0;
    return (subtotal / AppConstants.freeShippingThreshold).clamp(0.0, 1.0);
  }

  double get freeShippingAmountRemaining {
    if (subtotal >= AppConstants.freeShippingThreshold) return 0.0;
    return AppConstants.freeShippingThreshold - subtotal;
  }

  /// Total Amount to be charged via Stripe
  double get total => subtotal + tax + shipping;

  /// Add product to bag or increment quantity
  void addToCart(Product product, {int quantity = 1}) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  /// Toggle item addition
  void toggleItem(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items.removeAt(index);
    } else {
      _items.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }

  /// Update quantity directly
  void updateQuantity(String productId, int newQuantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  /// Remove item entirely
  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  /// Apply promo coupon code
  bool applyPromoCode(String code) {
    final clean = code.trim().toUpperCase();
    if (clean == 'IVORY10' || clean == 'VIP10') {
      _appliedPromoCode = clean;
      _discountPercentage = 0.10; // 10% discount
      notifyListeners();
      return true;
    } else if (clean == 'ATELIER20') {
      _appliedPromoCode = clean;
      _discountPercentage = 0.20; // 20% discount
      notifyListeners();
      return true;
    }
    return false;
  }

  void removePromoCode() {
    _appliedPromoCode = null;
    _discountPercentage = 0.0;
    notifyListeners();
  }

  /// Clear all bag contents (called after successful Stripe payment)
  void clearCart() {
    _items.clear();
    _appliedPromoCode = null;
    _discountPercentage = 0.0;
    notifyListeners();
  }
}
