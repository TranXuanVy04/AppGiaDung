import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AdminOrderService {
  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Future<List<dynamic>> getOrders(String token) async {
    final res = await http.get(
      Uri.parse('${ApiService.baseUrl}/Orders/admin'),
      headers: _headers(token),
    );

    if (res.statusCode != 200) {
      throw Exception('Không tải được đơn hàng: ${res.body}');
    }

    return jsonDecode(res.body);
  }

  Future<void> updateStatus(String token, int orderId, String status) async {
    final res = await http.put(
      Uri.parse('${ApiService.baseUrl}/Orders/$orderId/status'),
      headers: _headers(token),
      body: jsonEncode(status),
    );

    if (res.statusCode != 200) {
      throw Exception('Cập nhật thất bại: ${res.body}');
    }
  }
}