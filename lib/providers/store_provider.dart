// lib/providers/store_provider.dart
import 'package:flutter/foundation.dart';
import 'package:ispmanagement/models/cart_model.dart';
import '../models/order_item.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';

class StoreProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();

  List<Product> _products = [];
  List<dynamic> _categories = [];
  Cart? _cart;
  List<Order> _orders = [];
  bool _isLoading = false;

  // Getters
  List<Product> get products => _products;
  List<dynamic> get categories => _categories;
  Cart? get cart => _cart;
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  // Initialize store data
  Future<void> initStore() async {
    await fetchCategories();
    await fetchProducts();
    await fetchCart();
  }

  // Fetch all products or filtered products
  Future<void> fetchProducts({int? categoryId, bool? featured, String? search}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _productService.getProducts(
        categoryId: categoryId,
        featured: featured,
        search: search,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Fetch a specific product
  Future<Product?> fetchProductDetails(int productId) async {
    try {
      return await _productService.getProductDetails(productId);
    } catch (e) {
      rethrow;
    }
  }

  // Fetch categories
  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _productService.getCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Fetch user's cart
  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cart = await _cartService.getCart();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Add item to cart
  Future<void> addToCart(int productId, int quantity) async {
    try {
      _cart = await _cartService.addToCart(productId, quantity);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Update cart item quantity
  Future<void> updateCartItem(int itemId, int quantity) async {
    try {
      _cart = await _cartService.updateCartItem(itemId, quantity);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(int itemId) async {
    try {
      _cart = await _cartService.removeFromCart(itemId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    try {
      _cart = await _cartService.clearCart();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

// Fetch orders
  Future<List<Order>> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _orderService.getOrders();
      _isLoading = false;
      notifyListeners();
      return _orders;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Fetch order details
  Future<Order?> fetchOrderDetails(int orderId) async {
    try {
      return await _orderService.getOrderDetails(orderId);
    } catch (e) {
      rethrow;
    }
  }

  // Place order
  Future<Order> placeOrder(Map<String, dynamic> orderData) async {
    try {
      final order = await _orderService.createOrder(orderData);
      await fetchOrders(); // Refresh orders list
      await fetchCart(); // Refresh cart (should be empty now)
      return order!;
    } catch (e) {
      rethrow;
    }
  }

  // Cancel order
  Future<void> cancelOrder(int orderId) async {
    try {
      await _orderService.cancelOrder(orderId);
      await fetchOrders(); // Refresh orders list
    } catch (e) {
      rethrow;
    }
  }
}