import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/order_model.dart';
import 'api_service.dart';


class OrderService {
  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> createOrder({
    required String token,
    required String receiverName,
    required String receiverPhone,
    required String shippingAddress,
    required String paymentMethod,
    required double shippingFee,
    required List<int> selectedItemIds,
    String? voucherCode,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/Orders'),
      headers: _headers(token),
      body: jsonEncode({
        'receiverName': receiverName,
        'receiverPhone': receiverPhone,
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
        'shippingFee': shippingFee,
        'voucherCode': voucherCode,
        'selectedItemIds': selectedItemIds,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Đặt hàng thất bại: ${response.body}');
    }
  }

  Future<List<OrderModel>> getMyOrders(String token) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/Orders/my'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => OrderModel.fromJson(e)).toList();
    }

    throw Exception('Không tải được đơn hàng');
  }
  Future<void> cancelOrder(String token, int orderId) async {
    final res = await http.put(
      Uri.parse('${ApiService.baseUrl}/Orders/$orderId/cancel'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Hủy đơn thất bại: ${res.body}');
    }
  }
  Future<void> createBuyNowOrder({
    required String token,
    required int productId,
    required int quantity,
    required String receiverName,
    required String receiverPhone,
    required String shippingAddress,
    required String paymentMethod,
    required double shippingFee,
    String? voucherCode,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/Orders/buy-now'),
      headers: _headers(token),
      body: jsonEncode({
        'productId': productId,
        'quantity': quantity,
        'receiverName': receiverName,
        'receiverPhone': receiverPhone,
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
        'shippingFee': shippingFee,
        'voucherCode': voucherCode,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Đặt hàng thất bại');
    }
  }
}