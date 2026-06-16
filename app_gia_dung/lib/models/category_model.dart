class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final bool? isActive;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['isActive'],
    );
  }
}