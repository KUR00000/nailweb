import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/supabase_service.dart';

/// State management provider for the catalog, product search, category filtering, and sorting.
class CatalogProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _sortBy = 'featured'; // 'featured', 'price_asc', 'price_desc', 'rating'

  Product? _selectedProduct;

  List<Product> get allProducts => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  Product? get selectedProduct => _selectedProduct;

  static const List<String> categories = ['All', 'Press-On', 'Polish', 'Care'];

  CatalogProvider() {
    loadProducts();
  }

  /// Load products from Supabase (or fallback to the 13 verified items)
  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _supabaseService.fetchProducts();
    } catch (e) {
      _errorMessage = 'Failed to load catalog: $e';
      _products = Product.defaultProducts;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void selectProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  /// Get filtered and sorted products list
  List<Product> get filteredProducts {
    List<Product> result = List.from(_products);

    // Filter by Category
    if (_selectedCategory != 'All') {
      result = result
          .where((p) => p.category.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }

    // Filter by Search Query
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      result = result.where((p) {
        final matchName = p.name.toLowerCase().contains(query);
        final matchCategory = p.category.toLowerCase().contains(query);
        final matchDesc = p.description.toLowerCase().contains(query);
        return matchName || matchCategory || matchDesc;
      }).toList();
    }

    // Apply Sorting
    switch (_sortBy) {
      case 'price_asc':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'featured':
      default:
        // Keep initial curated order
        break;
    }

    return result;
  }
}
