import '../../models/product.dart';

/// Abstract catalog service for loading products.
abstract class CatalogService {
  Future<List<Product>> fetchProducts();
}
