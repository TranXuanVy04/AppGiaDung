import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AdminDashboardService {
  Future<Map<String, dynamic>> getDashboard(String token) async {
    final res = await http.get(
      Uri.parse('${ApiService.baseUrl}/Admin/dashboard'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Không tải được dashboard: ${res.body}');
    }

    return jsonDecode(res.body);
  }
}