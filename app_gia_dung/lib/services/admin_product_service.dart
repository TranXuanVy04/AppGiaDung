import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import 'api_service.dart';

class AdminProductService {
  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Future<List<ProductModel>> getProducts(String token) async {
    final res = await http.get(
      Uri.parse('${ApiService.baseUrl}/Products/admin'),
      headers: _headers(token),
    );

    if (res.statusCode != 200) {
      throw Exception('Không tải được sản phẩm: ${res.statusCode} - ${res.body}');
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<void> createProduct(String token, Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('${ApiService.baseUrl}/Products'),
      headers: _headers(token),
      body: jsonEncode(data),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Thêm sản phẩm thất bại: ${res.body}');
    }
  }

  Future<void> updateProduct(
      String token,
      int id,
      Map<String, dynamic> data,
      ) async {
    final res = await http.put(
      Uri.parse('${ApiService.baseUrl}/Products/$id'),
      headers: _headers(token),
      body: jsonEncode(data),
    );

    if (res.statusCode != 200) {
      throw Exception('Cập nhật thất bại: ${res.body}');
    }
  }

  Future<void> deleteProduct(String token, int id) async {
    final res = await http.delete(
      Uri.parse('${ApiService.baseUrl}/Products/$id'),
      headers: _headers(token),
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Xóa thất bại: ${res.body}');
    }
  }
}