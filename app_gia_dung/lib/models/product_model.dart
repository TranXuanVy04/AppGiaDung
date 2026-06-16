class ProductModel {
  final int id;
  final String name;
  final String? description;
  final double price;
  final double? oldPrice;
  final int stock;
  final String? brand;
  final String? imageUrl;
  final int categoryId;
  final double rating;
  final int soldCount;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.oldPrice,
    required this.stock,
    this.brand,
    this.imageUrl,
    required this.categoryId,
    required this.rating,
    required this.soldCount,
  });
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      oldPrice: json['oldPrice'] != null
          ? (json['oldPrice'] as num).toDouble()
          : null,
      stock: json['stock'] ?? 0,
      brand: json['brand'],
      imageUrl: json['imageUrl'],
      categoryId: json['categoryId'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      soldCount: json['soldCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'oldPrice': oldPrice,
      'stock': stock,
      'brand': brand,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'rating': rating,
    };
  }
}