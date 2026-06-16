import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/category_model.dart';
import 'api_service.dart';

class CategoryService {
  Future<List<CategoryModel>> getCategories() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/Categories'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    }

    throw Exception('Không tải được danh mục');
  }
}