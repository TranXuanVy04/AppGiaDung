import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/admin_product_service.dart';

class AdminProductProvider extends ChangeNotifier {
  final AdminProductService _service = AdminProductService();

  List<ProductModel> products = [];
  bool isLoading = false;

  Future<void> fetchProducts(String token) async {
    isLoading = true;
    notifyListeners();

    try {
      products = await _service.getProducts(token);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProduct(String token, Map<String, dynamic> data) async {
    await _service.createProduct(token, data);
    await fetchProducts(token);
  }

  Future<void> updateProduct(
      String token,
      int id,
      Map<String, dynamic> data,
      ) async {
    await _service.updateProduct(token, id, data);
    await fetchProducts(token);
  }

  Future<void> deleteProduct(String token, int id) async {
    await _service.deleteProduct(token, id);
    await fetchProducts(token);
  }
}