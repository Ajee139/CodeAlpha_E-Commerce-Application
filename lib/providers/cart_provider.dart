import 'package:flutter/material.dart';

class CartItem {
  final Map<String, dynamic> product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  void addToCart(Map<String, dynamic> product, {int quantity = 1}) {
    final productId = product['id'];
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity += quantity;
    } else {
      _items[productId] = CartItem(product: product, quantity: quantity);
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity = newQuantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double get totalPrice {
    return _items.values.fold(0.0, (total, item) {
      final price = item.product['price'];
      return total + (item.quantity * (price is num ? price.toDouble() : 0.0));
    });
  }

  int get totalItems {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }
}
