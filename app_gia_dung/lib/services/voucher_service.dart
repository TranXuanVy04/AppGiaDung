import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/voucher_model.dart';
import 'api_service.dart';

class VoucherService {
  Future<List<dynamic>> getAdminVouchers(String token) async {
    final res = await http.get(
      Uri.parse('${ApiService.baseUrl}/Vouchers/admin'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Không tải được voucher: ${res.body}');
    }

    return jsonDecode(res.body);
  }

  Future<void> createVoucher({
    required String token,
    required String code,
    required double discountAmount,
    required double minOrderAmount,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiService.baseUrl}/Vouchers'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'code': code,
        'title': code,
        'description': '',
        'discountType': 'Fixed',
        'discountValue': discountAmount,
        'minOrderValue': minOrderAmount,
        'expiredAt': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'isActive': true,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Thêm voucher thất bại');
    }
  }


  Future<void> deleteVoucher(String token, int id) async {
    final res = await http.delete(
      Uri.parse('${ApiService.baseUrl}/Vouchers/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Xoá voucher thất bại');
    }
  }
  Future<List<VoucherModel>> getVouchers() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/Vouchers'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => VoucherModel.fromJson(e)).toList();
    }

    throw Exception('Không tải được voucher');
  }

  Future<VoucherModel> applyVoucher({
    required String code,
    required double orderAmount,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/Vouchers/apply'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'code': code,
        'orderAmount': orderAmount,
      }),
    );

    if (response.statusCode == 200) {
      return VoucherModel.fromJson(jsonDecode(response.body));
    }

    final body = jsonDecode(response.body);
    throw Exception(body['message'] ?? 'Áp voucher thất bại');
  }
}