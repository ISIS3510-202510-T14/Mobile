import '../models/product_model.dart';
import '../services/database_helper.dart';

class ProductRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ------------------------ in-memory cache ------------------------
  static List<Product>? _cache;
  static DateTime? _cacheExpiry;
  static const Duration _cacheDuration = Duration(minutes: 10);

  /// Return cached products if the cache is valid, otherwise `null`.
  List<Product>? get memoryCache {
    if (_cache != null && _cacheExpiry != null) {
      if (DateTime.now().isBefore(_cacheExpiry!)) {
        return _cache;
      }
    }
    return null;
  }

  /// Update the in-memory cache with a fresh list of products.
  void updateCache(List<Product> products) {
    _cache = products;
    _cacheExpiry = DateTime.now().add(_cacheDuration);
  }

  /// Clear the in-memory cache.
  void clearCache() {
    _cache = null;
    _cacheExpiry = null;
  }

  Future<int> insertProduct(Product product) async {
    return await _dbHelper.insertProduct(product);
  }

  Future<Product?> getProduct(String id) async {
    return await _dbHelper.getProduct(id);
  }

  Future<List<Product>> getAllProducts() async {
    return await _dbHelper.getAllProducts();
  }

  Future<int> updateProduct(Product product) async {
    return await _dbHelper.updateProduct(product);
  }

  Future<int> deleteProduct(String id) async {
    return await _dbHelper.deleteProduct(id);
  }
}
