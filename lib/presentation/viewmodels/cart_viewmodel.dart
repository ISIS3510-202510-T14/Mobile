import 'dart:convert';

import 'package:campus_picks/presentation/viewmodels/marketplace_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/models/product_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/services/connectivity_service.dart';
import 'package:campus_picks/src/config.dart';
import 'package:campus_picks/data/services/auth.dart';
import 'package:campus_picks/data/services/database_helper.dart';

class CartViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final MarketplaceViewModel _marketplaceVM = MarketplaceViewModel();
  final List<CartItem> _items = [];
  final ConnectivityNotifier _conn;

  bool get isOffline => _conn.isOnline == false;

  CartViewModel({required ConnectivityNotifier connectivity})
      : _conn = connectivity {
    _conn.addListener(_onConnChanged);
    _loadCartItems(); // Carga desde DB al inicializar
  }

  List<CartItem> get items => List.unmodifiable(_items);

  double get totalAmount =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  int get itemCount => _items.length;

  Future<void> _loadCartItems() async {
    final userId = authService.value.currentUser?.uid;
    if (userId == null) return;

    final dbItems = await _dbHelper.getCartItems(userId);
    _items.clear();
    for (final item in dbItems) {
      final productId = item['productId'];
      final product = await fetchProductById(productId); // debes implementar esto
      if (product != null) {
        _items.add(CartItem(
          product: product,
          quantity: item['quantity'],
        ));
      }
    }
    notifyListeners();
  }

  Future<void> addToCart(Product product) async {
    final userId = authService.value.currentUser?.uid;
    if (userId == null) return;

    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      _items[index].quantity++;
      await _dbHelper.addCartItem(
        id: '${userId}_${product.id}',
        userId: userId,
        productId: product.id,
        quantity: _items[index].quantity,
      );
    } else {
      final newItem = CartItem(product: product);
      _items.add(newItem);
      await _dbHelper.addCartItem(
        id: '${userId}_${product.id}',
        userId: userId,
        productId: product.id,
        quantity: newItem.quantity,
      );
    }
    notifyListeners();
  }

  Future<void> removeFromCart(String productId) async {
    final userId = authService.value.currentUser?.uid;
    if (userId == null) return;

    _items.removeWhere((item) => item.product.id == productId);
    await _dbHelper.removeCartItem('${userId}_$productId');
    notifyListeners();
  }

  Future<void> clearCart() async {
    final userId = authService.value.currentUser?.uid;
    if (userId == null) return;

    _items.clear();
    await _dbHelper.clearCartItems(userId);
    notifyListeners();
  }

  Future<void> create() async {
    if (_items.isEmpty) return;

    final userId = authService.value.currentUser?.uid;
    if (userId == null) return;

    for (var item in _items) {
      final product = item.product;
      final quantity = item.quantity;

      final purchaseData = {
        'user_id': userId,
        'product_id': product.id,
        'quantity': quantity,
      };

      try {
        final response = await http.post(
          Uri.parse('${Config.apiBaseUrl}/api/purchases'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(purchaseData),
        );

        if (response.statusCode == 201) {
          print('Compra exitosa: ${product.name}');
        } else {
          print('Error al comprar ${product.name}: ${response.body}');
        }
      } catch (e) {
        print('Excepción en la compra de ${product.name}: $e');
      }
    }

    await clearCart(); // limpia memoria + base de datos
  }

  void _onConnChanged() => notifyListeners();

  @override
  void dispose() {
    _conn.removeListener(_onConnChanged);
    super.dispose();
  }

  Future<Product?> fetchProductById(String productId) async {
    _marketplaceVM.fetchProducts();
    final products = _marketplaceVM.products;
    for (final product in products) {
      if (product.id == productId) {
        return product;
      }
    }
    
    return null;
  }

}