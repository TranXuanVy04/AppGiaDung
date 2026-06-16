class PaymentMethodModel {
  final int id;
  final String name;
  final String code;
  final String? logoUrl;

  PaymentMethodModel({
    required this.id,
    required this.name,
    required this.code,
    this.logoUrl,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      logoUrl: json['logoUrl'],
    );
  }
}