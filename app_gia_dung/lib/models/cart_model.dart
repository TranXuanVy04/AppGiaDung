class CartItemApiModel {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? imageUrl;

  CartItemApiModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.imageUrl,
  });

  factory CartItemApiModel.fromJson(Map<String, dynamic> json) {
    return CartItemApiModel(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      quantity: json['quantity'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      imageUrl: json['imageUrl'],
    );
  }
}

class CartApiModel {
  final int id;
  final int userId;
  final List<CartItemApiModel> items;
  final double totalAmount;

  CartApiModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
  });

  factory CartApiModel.fromJson(Map<String, dynamic> json) {
    return CartApiModel(
      id: json['id'],
      userId: json['userId'],
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItemApiModel.fromJson(e))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );
  }
}