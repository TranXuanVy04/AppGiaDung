import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/Auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return UserModel.fromJson(
        data['user'],
        token: data['token'],
      );
    } else {
      throw Exception('Đăng nhập thất bại');
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String address,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/Auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'address': address,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Đăng ký thất bại');
    }
  }
}