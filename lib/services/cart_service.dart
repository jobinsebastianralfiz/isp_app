import 'package:ispmanagement/models/cart_model.dart';

import 'api_service.dart';

class CartService {
  final ApiService _apiService;
  final String _endpoint = 'api/store/carts';

  CartService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<Cart?> getCart() async {
    try {
      final response = await _apiService.get('$_endpoint/');
      print('DEBUG: Cart Response: $response');
      return Cart.fromJson(response);
    } catch (e) {
      print('Error fetching cart: $e');
      return null;
    }
  }

  Future<Cart?> addToCart(int productId, int quantity) async {
    try {
      final response = await _apiService.post(
        '$_endpoint/add_item/',
        data: {
          'product_id': productId,
          'quantity': quantity,
        },
      );
      print('DEBUG: Add to Cart Response: $response');
      return Cart.fromJson(response);
    } catch (e) {
      print('Error adding to cart: $e');
      return null;
    }
  }

  Future<Cart?> updateCartItem(int itemId, int quantity) async {
    try {
      final response = await _apiService.post(
        '$_endpoint/update_item/',
        data: {
          'item_id': itemId,
          'quantity': quantity,
        },
      );
      print('DEBUG: Update Cart Item Response: $response');
      return Cart.fromJson(response);
    } catch (e) {
      print('Error updating cart item: $e');
      return null;
    }
  }

  Future<Cart?> removeFromCart(int itemId) async {
    try {
      final response = await _apiService.post(
        '$_endpoint/remove_item/',
        data: {
          'item_id': itemId,
        },
      );
      print('DEBUG: Remove from Cart Response: $response');
      return Cart.fromJson(response);
    } catch (e) {
      print('Error removing from cart: $e');
      return null;
    }
  }

  Future<Cart?> clearCart() async {
    try {
      final response = await _apiService.post('$_endpoint/clear/');
      print('DEBUG: Clear Cart Response: $response');
      return Cart.fromJson(response);
    } catch (e) {
      print('Error clearing cart: $e');
      return null;
    }
  }
}