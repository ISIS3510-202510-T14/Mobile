import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/models/cart_item_model.dart';

class CartViewModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  double get totalAmount =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  /// Returns the number of unique product lines in the cart.
  int get itemCount => _items.length; // <-- ADDED THIS LINE

  void addToCart(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      // Product already exists in cart, increment its quantity
      _items[index].quantity++;
    } else {
      // Product is new to the cart
      _items.add(CartItem(product: product));
    }
    print("Added to cart: ${product.name}, Current unique items: ${_items.length}");
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

}