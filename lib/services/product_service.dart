// lib/services/store/product_service.dart
import 'package:dio/dio.dart';
import 'package:ispmanagement/models/product_model.dart';
import 'package:ispmanagement/services/api_service.dart';

class ProductService {
  final ApiService _apiService;

  // URLs match the Django router.register() paths
  final String _endpoint = 'api/store/products/';
  final String _categoriesEndpoint = 'api/store/categories/';

  ProductService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();
  Future<List<Product>> getProducts({
    int? categoryId,
    bool? featured,
    String? search,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {};

      if (categoryId != null) {
        queryParameters['category'] = categoryId.toString();
      }

      if (featured != null) {
        queryParameters['featured'] = featured.toString().toLowerCase();
      }

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      final response = await _apiService.get(
        _endpoint,
        queryParameters: queryParameters,
      );

      print('DEBUG: Received Products Response: $response');

      // Handle paginated response
      if (response is Map && response.containsKey('results')) {
        List<dynamic> results = response['results'];
        return results.map<Product>((item) => Product.fromJson(item)).toList();
      } else if (response is List) {
        return response.map<Product>((item) => Product.fromJson(item)).toList();
      } else {
        print('Unexpected response format for products');
        return [];
      }
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  Future<List<dynamic>> getCategories() async {
    try {
      final response = await _apiService.get(_categoriesEndpoint);

      print('DEBUG: Received Categories Response: $response');

      // Handle paginated response
      if (response is Map && response.containsKey('results')) {
        return response['results'];
      } else if (response is List) {
        return response;
      } else {
        print('Unexpected response format for categories');
        return [];
      }
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }
  // Get product details - matches '/products/{pk}/'
  Future<Product?> getProductDetails(int productId) async {
    try {
      final response = await _apiService.get('$_endpoint/$productId/');
      return Product.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Get product reviews - matches '/products/{pk}/reviews/'
  Future<List<dynamic>> getProductReviews(int productId) async {
    try {
      final response = await _apiService.get('$_endpoint/$productId/reviews/');
      if (response is List) {
        return response;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Add product review - matches '/products/{pk}/add_review/'
  Future<Map<String, dynamic>?> addProductReview(
      int productId,
      double rating,
      String comment
      ) async {
    try {
      final data = {
        'rating': rating,
        'comment': comment,
      };

      final response = await _apiService.post(
        '$_endpoint/$productId/add_review/',
        data: data,
      );

      return response;
    } catch (e) {
      return null;
    }
  }


}