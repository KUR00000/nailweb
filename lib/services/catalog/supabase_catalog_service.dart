import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/product.dart';
import 'catalog_service.dart';

/// Production catalog service querying customer's Supabase project.
class SupabaseCatalogService implements CatalogService {
  final SupabaseClient _client;

  SupabaseCatalogService(this._client);

  @override
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _client
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

    // Curated fallback if catalog table is not yet seeded
    return Product.defaultProducts;
  }
}
