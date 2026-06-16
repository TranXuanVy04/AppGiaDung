import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../models/payment_method_model.dart';

class PaymentService {


  Future<List<PaymentMethodModel>> getMethods() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/Payments/methods'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .map((e) => PaymentMethodModel.fromJson(e))
          .toList();
    }

    return [];
  }
}