// lib/services/store/order_service.dart
import 'dart:developer' as dev;
import 'package:ispmanagement/models/order_item.dart';
import 'package:ispmanagement/services/api_service.dart';

// lib/services/store/order_service.dart
class OrderService {
  final ApiService _apiService;

  // URL matches the router.register() with basename='order'
  final String _endpoint = 'api/store/orders/';

  OrderService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Get user's orders - matches default list view
  // Get user's orders - matches default list view
  Future<List<Order>> getOrders() async {
    try {
      final response = await _apiService.get(_endpoint);
      dev.log('Orders response: $response');

      // Check if response is paginated (contains 'results' field)
      if (response is Map && response.containsKey('results')) {
        if (response['results'] is List) {
          return response['results']
              .map<Order>((item) => Order.fromJson(item))
              .toList();
        }
      }

      // Handle direct list response (not paginated)
      if (response is List) {
        return response.map<Order>((item) => Order.fromJson(item)).toList();
      }

      dev.log('Unexpected response format for orders: $response');
      return [];
    } catch (e) {
      dev.log('Error fetching orders: $e');
      return [];
    }
  }

  // Get order details - matches default retrieve view
  Future<Order?> getOrderDetails(int orderId) async {
    try {
      final response = await _apiService.get('$_endpoint/$orderId/');
      return Order.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Create a new order - matches default create view
  Future<Order?> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _apiService.post(
        _endpoint,
        data: orderData,
      );

      return Order.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Cancel an order - matches '/cancel/' action
  Future<Map<String, dynamic>?> cancelOrder(int orderId) async {
    try {
      final response = await _apiService.post('$_endpoint/$orderId/cancel/');
      return response;
    } catch (e) {
      return null;
    }
  }
}