import 'package:flutter/material.dart';
import 'package:ispmanagement/models/pacakge_models.dart';
import '../models/api_response.dart';



import '../services/package_service.dart';

class PackageProvider extends ChangeNotifier {
  final PackageService _packageService = PackageService();

  ApiResponse<List<Package>> _packagesResponse = ApiResponse.completed([]);
  ApiResponse<UserPackage?> _subscriptionResponse = ApiResponse.completed(null);
  ApiResponse<List<UserPackage>> _userSubscriptionsResponse = ApiResponse.completed([]);
  ApiResponse<bool> _cancelSubscriptionResponse = ApiResponse.completed(false);

  // Getters
  ApiResponse<List<Package>> get packagesResponse => _packagesResponse;
  ApiResponse<UserPackage?> get subscriptionResponse => _subscriptionResponse;
  ApiResponse<List<UserPackage>> get userSubscriptionsResponse => _userSubscriptionsResponse;
  ApiResponse<bool> get cancelSubscriptionResponse => _cancelSubscriptionResponse;

  List<Package> get packages => _packagesResponse.data ?? [];
  UserPackage? get currentSubscription => _subscriptionResponse.data;
  List<UserPackage> get userSubscriptions => _userSubscriptionsResponse.data ?? [];

  bool get isLoading =>
      _packagesResponse.isLoading ||
          _subscriptionResponse.isLoading ||
          _userSubscriptionsResponse.isLoading ||
          _cancelSubscriptionResponse.isLoading;

  // Get all available packages
  Future<void> getPackages() async {
    _packagesResponse = ApiResponse.loading();
    notifyListeners();

    try {
      final packages = await _packageService.getPackages();
      _packagesResponse = ApiResponse.completed(packages);
    } catch (e) {
      _packagesResponse = ApiResponse.error(e.toString());
    }

    notifyListeners();
  }

  // Subscribe to a package
  Future<void> subscribeToPackage(
      int packageId,
      String paymentId,
      String orderId,
      String signature
      ) async {
    _subscriptionResponse = ApiResponse.loading();
    notifyListeners();

    try {
      final request = SubscriptionRequest(
        paymentId: paymentId,
        orderId: orderId,
        signature: signature,
      );

      final subscription = await _packageService.subscribeToPackage(packageId, request);
      _subscriptionResponse = ApiResponse.completed(subscription);

      // Refresh user subscriptions after subscribing
      if (subscription != null) {
        await getUserSubscriptions();
      }
    } catch (e) {
      _subscriptionResponse = ApiResponse.error(e.toString());
    }

    notifyListeners();
  }

  // Get user's subscriptions
  Future<void> getUserSubscriptions() async {
    _userSubscriptionsResponse = ApiResponse.loading();
    notifyListeners();

    try {
      final subscriptions = await _packageService.getUserSubscriptions();
      _userSubscriptionsResponse = ApiResponse.completed(subscriptions);
    } catch (e) {
      _userSubscriptionsResponse = ApiResponse.error(e.toString());
    }

    notifyListeners();
  }

  // Get user's current subscription
  Future<void> getCurrentSubscription() async {
    _subscriptionResponse = ApiResponse.loading();
    notifyListeners();

    try {
      final subscription = await _packageService.getCurrentSubscription();
      _subscriptionResponse = ApiResponse.completed(subscription);
    } catch (e) {
      _subscriptionResponse = ApiResponse.error(e.toString());
    }

    notifyListeners();
  }

  // Cancel a subscription
  Future<void> cancelSubscription(int subscriptionId) async {
    _cancelSubscriptionResponse = ApiResponse.loading();
    notifyListeners();

    try {
      final result = await _packageService.cancelSubscription(subscriptionId);
      _cancelSubscriptionResponse = ApiResponse.completed(result);

      // Refresh user subscriptions after cancelling
      if (result) {
        await getUserSubscriptions();
        await getCurrentSubscription();
      }
    } catch (e) {
      _cancelSubscriptionResponse = ApiResponse.error(e.toString());
    }

    notifyListeners();
  }

  // Reset states
  void resetState() {
    _packagesResponse = ApiResponse.completed([]);
    _subscriptionResponse = ApiResponse.completed(null);
    _userSubscriptionsResponse = ApiResponse.completed([]);
    _cancelSubscriptionResponse = ApiResponse.completed(false);
    notifyListeners();
  }
}