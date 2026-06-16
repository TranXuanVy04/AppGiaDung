import 'package:flutter/material.dart';
import '../services/admin_order_service.dart';

class AdminOrderProvider extends ChangeNotifier {
  final AdminOrderService _service = AdminOrderService();

  List<dynamic> orders = [];
  bool isLoading = false;

  Future<void> fetchOrders(String token) async {
    isLoading = true;
    notifyListeners();

    try {
      orders = await _service.getOrders(token);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String token, int orderId, String status) async {
    await _service.updateStatus(token, orderId, status);
    await fetchOrders(token);
  }
}