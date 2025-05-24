import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_view_repository.dart';
import '../../data/services/connectivity_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/productView_sync_service.dart';

class ProductDetailViewModel extends ChangeNotifier {
  final Product product;
  final ProductViewsRepository _viewsRepo;
  final ConnectivityNotifier _conn;

  bool get isOffline => _conn.isOnline == false;

  int _viewCount = 0;
  int get viewCount => _viewCount;

  ProductDetailViewModel({
    required this.product,
    required ConnectivityNotifier connectivity,
    ProductViewsRepository? viewsRepo,
  })  : _conn = connectivity,
        _viewsRepo = viewsRepo ?? ProductViewsRepository() {
    _initialize();
    _conn.addListener(_onConnChanged);
  }

  Future<void> _initialize() async {
    // 1) registra la vista
    print("Product ID: ${product.id}");

    //uid de usuario firebase
    final uid = FirebaseAuth.instance.currentUser!.uid;  
    await _viewsRepo.registerView(product.id, uid);
    // 2) consulta cuántas veces se ha visto
    _viewCount = await _viewsRepo.timesViewed(product.id);
    notifyListeners();


     if (_conn.isOnline) {
      await ProductViewSyncService.instance.syncNow();
    }
  }

  void _onConnChanged() => notifyListeners();

  @override
  void dispose() {
    _conn.removeListener(_onConnChanged);
    super.dispose();
  }
}
