import 'package:flutter/material.dart';

import '../models/cart_model.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  CartApiModel? cart;
  bool isLoading = false;

  List<CartItemApiModel> get items => cart?.items ?? [];
  double get totalPrice => cart?.totalAmount ?? 0;

  Future<void> fetchCart(String token) async {
    try {
      isLoading = true;
      notifyListeners();

      cart = await _cartService.getMyCart(token);
      _selectedItemIds.removeWhere(
              (id) => !items.any((item) => item.id == id),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart({
    required String token,
    required int productId,
    required int quantity,
  }) async {
    await _cartService.addToCart(
      token: token,
      productId: productId,
      quantity: quantity,
    );
    await fetchCart(token);
  }

  Future<void> increaseQuantity({
    required String token,
    required CartItemApiModel item,
  }) async {
    await _cartService.updateCartItem(
      token: token,
      cartItemId: item.id,
      quantity: item.quantity + 1,
    );
    await fetchCart(token);
  }

  Future<void> decreaseQuantity({
    required String token,
    required CartItemApiModel item,
  }) async {
    if (item.quantity <= 1) {
      await removeFromCart(token: token, cartItemId: item.id);
      return;
    }

    await _cartService.updateCartItem(
      token: token,
      cartItemId: item.id,
      quantity: item.quantity - 1,
    );
    await fetchCart(token);
  }

  Future<void> removeFromCart({
    required String token,
    required int cartItemId,
  }) async {
    await _cartService.removeCartItem(token: token, cartItemId: cartItemId);
    await fetchCart(token);
  }

  void clearCartLocal() {
    cart = null;
    notifyListeners();
  }

  int get totalItemsCount {
    int total = 0;
    for (final item in items) {
      total += item.quantity;
    }
    return total;
  }

  // ... các biến hiện có (items, isLoading...)

  // Danh sách lưu ID các sản phẩm được tích chọn
  final Set<int> _selectedItemIds = {};

  Set<int> get selectedItemIds => _selectedItemIds;

  // Tính tổng tiền chỉ cho những sản phẩm được tích chọn
  double get selectedTotalPrice {
    return items
        .where((item) => _selectedItemIds.contains(item.id))
        .fold(0, (sum, item) => sum + (item.unitPrice * item.quantity));
  }

  // Logic tích chọn từng mục
  void toggleItemSelection(int itemId) {
    if (_selectedItemIds.contains(itemId)) {
      _selectedItemIds.remove(itemId);
    } else {
      _selectedItemIds.add(itemId);
    }
    notifyListeners();
  }

  // Logic tích chọn tất cả
  void toggleAll(bool selectAll) {
    if (selectAll) {
      _selectedItemIds.addAll(items.map((e) => e.id));
    } else {
      _selectedItemIds.clear();
    }
    notifyListeners();
  }

  // Cập nhật lại fetchCart để clear selection nếu cần
  // void fetchCart(...) { ... _selectedItemIds.clear(); notifyListeners(); }
}
