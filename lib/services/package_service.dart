import 'dart:developer';
import 'package:ispmanagement/models/pacakge_models.dart';

import '../config/api_endpoints.dart';

import '../services/api_service.dart';

class PackageService {
  final ApiService _apiService = ApiService();

  // Get all available packages
  Future<List<Package>> getPackages() async {
    try {
      log('Fetching packages from server');
      final response = await _apiService.get(ApiEndpoints.packages);

      log('Packages response: $response');

      if (response != null) {
        // Handle Django REST Framework's paginated response format
        if (response is Map && response.containsKey('results')) {
          // Paginated format: { count, next, previous, results: [...] }
          final List<Package> packages = (response['results'] as List)
              .map((item) => Package.fromJson(item))
              .toList();

          return packages;
        } else if (response is List) {
          // Regular list format
          final List<Package> packages = response
              .map((item) => Package.fromJson(item))
              .toList();

          return packages;
        }
      }

      return [];
    } catch (e) {
      log('Error fetching packages: $e');
      rethrow;
    }
  }

  // Subscribe to a package
  Future<UserPackage?> subscribeToPackage(int packageId, SubscriptionRequest request) async {
    try {
      final url = ApiEndpoints.getUrlWithPathParam(
        ApiEndpoints.subscribePackage,
        'id',
        packageId.toString(),
      );

      final response = await _apiService.post(
        url,
        data: request.toJson(),
      );

      if (response != null && response.containsKey('subscription')) {
        return UserPackage.fromJson(response['subscription']);
      }

      return null;
    } catch (e) {
      log('Error subscribing to package: $e');
      rethrow;
    }
  }

  // Get user's subscriptions
  Future<List<UserPackage>> getUserSubscriptions() async {
    try {
      final response = await _apiService.get(ApiEndpoints.userSubscriptions);

      if (response != null) {
        if (response is Map && response.containsKey('results')) {
          // Paginated results
          final List<UserPackage> subscriptions = (response['results'] as List)
              .map((item) => UserPackage.fromJson(item))
              .toList();

          return subscriptions;
        } else if (response is List) {
          // Regular list
          final List<UserPackage> subscriptions = response
              .map((item) => UserPackage.fromJson(item))
              .toList();

          return subscriptions;
        }
      }

      return [];
    } catch (e) {
      log('Error fetching user subscriptions: $e');
      rethrow;
    }
  }

  // Get user's current active subscription
  Future<UserPackage?> getCurrentSubscription() async {
    try {
      final response = await _apiService.get(ApiEndpoints.currentSubscription);

      if (response != null) {
        return UserPackage.fromJson(response);
      }

      return null;
    } catch (e) {
      log('Error fetching current subscription: $e');
      // If user has no active subscription, API will return 404
      return null;
    }
  }

  // Cancel a subscription
  Future<bool> cancelSubscription(int subscriptionId) async {
    try {
      final url = ApiEndpoints.getUrlWithPathParam(
        ApiEndpoints.cancelSubscription,
        'id',
        subscriptionId.toString(),
      );

      final response = await _apiService.post(url);

      return response != null && response.containsKey('message');
    } catch (e) {
      log('Error cancelling subscription: $e');
      rethrow;
    }
  }
}