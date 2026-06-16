import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<CategoryModel> categories = [];
  bool isLoading = false;

  Future<void> fetchCategories() async {
    try {
      isLoading = true;
      notifyListeners();

      categories = await _categoryService.getCategories();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}