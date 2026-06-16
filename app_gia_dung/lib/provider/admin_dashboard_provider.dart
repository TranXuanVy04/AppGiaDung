import 'package:flutter/material.dart';
import '../services/admin_dashboard_service.dart';

class AdminDashboardProvider extends ChangeNotifier {
  final AdminDashboardService _service = AdminDashboardService();

  Map<String, dynamic>? data;
  bool isLoading = false;

  Future<void> fetchDashboard(String token) async {
    isLoading = true;
    notifyListeners();

    try {
      data = await _service.getDashboard(token);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}