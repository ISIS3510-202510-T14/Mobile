// lib/data/repositories/product_views_repository.dart
import '../services/database_helper.dart';

class ProductViewsRepository {
  final DatabaseHelper _db;
  ProductViewsRepository({DatabaseHelper? dbHelper})
      : _db = dbHelper ?? DatabaseHelper();

  Future<void> registerView(String productId, String userID) =>
      _db.insertProductView(productId, userID);

  Future<int> timesViewed(String productId) =>
      _db.countProductViews(productId);


  Future<int> timesViewedByUser(String productId, String userId) =>
      _db.countProductViewsByUser(productId, userId);


  // Future<List<Map<String, dynamic>>> recent({int limit = 20}) =>
  //     _db.lastProductViews(limit: limit);

  Future<void> deleteForProduct(String productId) =>
      _db.deleteProductViews(productId);

   Future<List<Map<String, dynamic>>> pendingViews({int limit = 500}) =>
      _db.getPendingProductViews(limit: limit);

  Future<void> clear() => _db.clearProductViews();


    Future<void> markViewsSynced(List<int> ids) =>
      _db.markProductViewsSynced(ids);

}
