import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  List<ProductModel> products = [];
  bool isLoading = false;

  int? selectedCategoryId;

  Future<void> fetchProducts({
    String? keyword,
    int? categoryId,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      selectedCategoryId = categoryId;

      String url = "${ApiService.baseUrl}/Products";
      final queryParams = <String>[];

      if (keyword != null && keyword.isNotEmpty) {
        queryParams.add("keyword=$keyword");
      }

      if (categoryId != null) {
        queryParams.add("categoryId=$categoryId");
      }

      if (queryParams.isNotEmpty) {
        url += "?${queryParams.join("&")}";
      }

      debugPrint("Calling API: $url");

      final response = await http.get(Uri.parse(url));

      debugPrint("Status code: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        products = data.map((e) {
          return ProductModel(
            id: e['id'],
            name: e['name'],
            description: e['description'],
            price: (e['price'] as num).toDouble(),
            oldPrice: e['oldPrice'] != null
                ? (e['oldPrice'] as num).toDouble()
                : null,
            stock: e['stock'],
            brand: e['brand'],
            imageUrl: e['imageUrl'],
            categoryId: e['categoryId'],
            rating: (e['rating'] as num).toDouble(),
            soldCount: e['soldCount'] ?? 0,
          );
        }).toList();
      } else {
        products = [];
      }
    } catch (e) {
      debugPrint("Error fetchProducts: $e");
      products = [];
    }

    isLoading = false;
    notifyListeners();
  }

  void clearProducts() {
    products = [];
    notifyListeners();
  }
}