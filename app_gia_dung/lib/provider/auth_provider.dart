import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? currentUser;
  bool isLoading = false;
  UserModel? _user;

  UserModel? get user => _user;
  int? get userId => _user?.id;

  String? get token => currentUser?.token;
  bool get isLoggedIn => currentUser != null;


  Future<bool> login(String username, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      final user = await _authService.login(
        username: username,
        password: password,
      );

      currentUser = user;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson()));

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('user_data');

    if (data != null) {
      final json = jsonDecode(data);
      currentUser = UserModel.fromStorage(json);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    notifyListeners();
  }
}