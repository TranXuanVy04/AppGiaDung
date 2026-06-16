import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/order_model.dart';
import '../services/order_service.dart';
import '../services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> orders = [];
  bool isLoading = false;

  Future<void> fetchMyOrders(String token) async {
    try {
      isLoading = true;
      notifyListeners();

      orders = await _orderService.getMyOrders(token);
    } finally {
      isLoading = false;
      notifyListeners();
    }
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

    await fetchMyOrders(token);
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
    await _orderService.createOrder(
      token: token,
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      shippingFee: shippingFee,
      voucherCode: voucherCode,
      selectedItemIds: selectedItemIds,
    );

    await fetchMyOrders(token);
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
    await _orderService.createBuyNowOrder(
      token: token,
      productId: productId,
      quantity: quantity,
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      shippingFee: shippingFee,
      voucherCode: voucherCode,
    );

    await fetchMyOrders(token);
  }

}