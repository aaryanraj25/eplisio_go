class ProductModel {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final double price;
  final String manufacturer;
  final bool isActive;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
    required this.manufacturer,
    required this.isActive,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      manufacturer: json['manufacturer'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }
}