import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ReviewService {
  Future<List<dynamic>> getReviews(int productId) async {
    final res = await http.get(
      Uri.parse('${ApiService.baseUrl}/ProductReviews/product/$productId'),
    );

    if (res.statusCode != 200) {
      throw Exception('Không tải được đánh giá');
    }

    return jsonDecode(res.body);
  }

  Future<void> createReview({
    required String token,
    required int productId,
    required int orderId,
    required int rating,
    required String comment,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiService.baseUrl}/ProductReviews'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'productId': productId,
        'orderId': orderId,
        'rating': rating,
        'comment': comment,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Đánh giá thất bại: ${res.body}');
    }
  }
}