import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/cart_model.dart';
import 'api_service.dart';

class CartService {
  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<CartApiModel> getMyCart(String token) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/Cart'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return CartApiModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Không tải được giỏ hàng');
  }

  Future<void> addToCart({
    required String token,
    required int productId,
    required int quantity,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/Cart/add'),
      headers: _headers(token),
      body: jsonEncode({'productId': productId, 'quantity': quantity}),
    );

    if (response.statusCode != 200) {
      throw Exception('Thêm vào giỏ hàng thất bại');
    }
  }

  Future<void> updateCartItem({
    required String token,
    required int cartItemId,
    required int quantity,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiService.baseUrl}/Cart/items/$cartItemId'),
      headers: _headers(token),
      body: jsonEncode({'quantity': quantity}),
    );

    if (response.statusCode != 200) {
      throw Exception('Cập nhật giỏ hàng thất bại');
    }
  }

  Future<void> removeCartItem({
    required String token,
    required int cartItemId,
  }) async {
    final response = await http.delete(
      Uri.parse('${ApiService.baseUrl}/Cart/items/$cartItemId'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Xóa sản phẩm thất bại');
    }
  }
}
