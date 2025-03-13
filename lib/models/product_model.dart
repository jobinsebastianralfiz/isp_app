// lib/models/product.dart
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final bool isActive;
  final bool isFeatured;
  final String categoryName;
  final int categoryId;
  final List<String> images;
  final double averageRating;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.isActive,
    required this.isFeatured,
    required this.categoryName,
    required this.categoryId,
    required this.images,
    this.averageRating = 0.0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> imageUrls = [];
    if (json['images'] != null) {
      imageUrls = (json['images'] as List).map((img) => img['image']).cast<String>().toList();
    }

    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      stock: json['stock'] ?? 0,
      isActive: json['is_active'] ?? true,
      isFeatured: json['is_featured'] ?? false,
      categoryName: json['category']['name'],
      categoryId: json['category']['id'],
      images: imageUrls,
      averageRating: json['average_rating'] != null
          ? double.parse(json['average_rating'].toString())
          : 0.0,
    );
  }

  // Add the empty factory method
  factory Product.empty() {
    return Product(
      id: 0,
      name: 'Unknown Product',
      description: '',
      price: 0.0,
      stock: 0,
      isActive: false,
      isFeatured: false,
      categoryName: 'Unknown',
      categoryId: 0,
      images: [],
      averageRating: 0.0,
    );
  }
}