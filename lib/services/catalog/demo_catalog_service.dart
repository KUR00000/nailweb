import '../../models/product.dart';
import 'catalog_service.dart';

/// Catalog service for Atelier Demo mode returning the 13 verified items.
class DemoCatalogService implements CatalogService {
  @override
  Future<List<Product>> fetchProducts() async {
    return Product.defaultProducts;
  }
}
