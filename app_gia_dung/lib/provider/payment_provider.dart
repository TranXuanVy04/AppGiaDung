import 'package:flutter/material.dart';

import '../models/payment_method_model.dart';
import '../services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _service = PaymentService();

  List<PaymentMethodModel> methods = [];

  PaymentMethodModel? selectedMethod;

  bool isLoading = false;

  Future<void> fetchMethods() async {
    isLoading = true;
    notifyListeners();

    methods = await _service.getMethods();

    if (methods.isNotEmpty) {
      selectedMethod = methods.first;
    }

    isLoading = false;
    notifyListeners();
  }

  void selectMethod(PaymentMethodModel method) {
    selectedMethod = method;
    notifyListeners();
  }
}