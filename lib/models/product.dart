// lib/models/product.dart

class Product {
  final int id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.description = 'No description available.',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      imageUrl: json['image'] as String,
      description: json['description'] as String? ?? 'No description available.',
    );
  }
}
