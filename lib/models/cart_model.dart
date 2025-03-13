// lib/models/cart.dart
import 'package:ispmanagement/models/product_model.dart';

class CartItem {
  final int id;
  final Product product;
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    this.quantity = 1,
  });

  double get subtotal => product.price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }
}

class Cart {
  final int id;
  final List<CartItem> items;
  final double total;
  final int itemCount;

  Cart({
    required this.id,
    required this.items,
    required this.total,
    required this.itemCount,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    List<CartItem> cartItems = [];
    if (json['items'] != null) {
      cartItems = (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList();
    }

    return Cart(
      id: json['id'],
      items: cartItems,
      total: double.parse(json['total'].toString()),
      itemCount: json['item_count'],
    );
  }
}