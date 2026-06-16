import 'package:flutter/material.dart';

import '../models/product_model.dart';

class WishlistProvider extends ChangeNotifier {
  final List<ProductModel> _items = [];

  List<ProductModel> get items => _items;

  bool isFavorite(int productId) {
    return _items.any((e) => e.id == productId);
  }

  void toggleWishlist(ProductModel product) {
    final exists = _items.any((e) => e.id == product.id);

    if (exists) {
      _items.removeWhere((e) => e.id == product.id);
    } else {
      _items.add(product);
    }

    notifyListeners();
  }
}