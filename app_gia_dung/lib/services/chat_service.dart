import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ChatService {
  Future<List<dynamic>> getMessages(String token, int receiverId) async {
    final res = await http.get(
      Uri.parse('${ApiService.baseUrl}/Chat/$receiverId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Không tải được tin nhắn');
    }

    return jsonDecode(res.body);
  }

  Future<void> sendMessage({
    required String token,
    required int receiverId,
    required String message,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiService.baseUrl}/Chat'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'receiverId': receiverId,
        'message': message,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Gửi tin nhắn thất bại');
    }
  }

  Future<List<dynamic>> getChatUsers(String token) async {
    final res = await http.get(
      Uri.parse('${ApiService.baseUrl}/Chat/users'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Không tải được danh sách khách');
    }

    return jsonDecode(res.body);
  }
}