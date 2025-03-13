import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ispmanagement/models/billing_model.dart';

import '../models/connection_models.dart';

import '../models/api_response.dart';
import '../controllers/connection_controller.dart';
import '../models/pacakge_models.dart';
import '../services/connection_service.dart';

class ConnectionProvider extends ChangeNotifier {
  final ConnectionService _connectionService = ConnectionService();

  // State variables
  ApiResponse<List<ConnectionApplication>> _applicationsResponse = ApiResponse.completed([]);
  ApiResponse<ConnectionApplication?> _applicationResponse = ApiResponse.completed(null);
  ApiResponse<ConnectionApplication?> _activeConnectionResponse = ApiResponse.completed(null);
  ApiResponse<List<Package>> _packagesResponse = ApiResponse.completed([]);
  ApiResponse<ApplicationDocument?> _documentUploadResponse = ApiResponse.completed(null);

  // Selected package for new applications
  Package? _selectedPackage;
  ApiResponse<MonthlyBilling?> _currentBillingResponse = ApiResponse.completed(null);
  ApiResponse<List<MonthlyBilling>> _billingHistoryResponse = ApiResponse.completed([]);

// Add these getters to your ConnectionProvider class
  ApiResponse<MonthlyBilling?> get currentBillingResponse => _currentBillingResponse;
  ApiResponse<List<MonthlyBilling>> get billingHistoryResponse => _billingHistoryResponse;

  MonthlyBilling? get currentBilling => _currentBillingResponse.data;
  List<MonthlyBilling> get billingHistory => _billingHistoryResponse.data ?? [];

  // Getters
  ApiResponse<List<ConnectionApplication>> get applicationsResponse => _applicationsResponse;
  ApiResponse<ConnectionApplication?> get applicationResponse => _applicationResponse;
  ApiResponse<ConnectionApplication?> get activeConnectionResponse => _activeConnectionResponse;
  ApiResponse<List<Package>> get packagesResponse => _packagesResponse;
  ApiResponse<ApplicationDocument?> get documentUploadResponse => _documentUploadResponse;

  Package? get selectedPackage => _selectedPackage;
  List<ConnectionApplication> get applications => _applicationsResponse.data ?? [];
  ConnectionApplication? get application => _applicationResponse.data;
  ConnectionApplication? get activeConnection => _activeConnectionResponse.data;
  List<Package> get packages => _packagesResponse.data ?? [];

  bool get isLoading =>
      _applicationsResponse.isLoading ||
          _applicationResponse.isLoading ||
          _activeConnectionResponse.isLoading ||
          _packagesResponse.isLoading ||
          _documentUploadResponse.isLoading||
  _currentBillingResponse.isLoading ||
  _billingHistoryResponse.isLoading;

  // Initialize - load active connection
  Future<void> initialize() async {
    await getActiveConnection();
    await getPackages();
    if (activeConnection != null) {
      await getCurrentBilling();
      await getBillingHistory();
    }
  }
  Future<void> getCurrentBilling() async {
    _currentBillingResponse = ApiResponse.loading();
    notifyListeners();

    try {
      final billing = await _connectionService.getCurrentBilling();
      _currentBillingResponse = ApiResponse.completed(billing);
    } catch (e) {
      _currentBillingResponse = ApiResponse.error(e.toString());
    }

    notifyListeners();
  }
  Future<void> getBillingHistory() async {
    _billingHistoryResponse = ApiResponse.loading();
    notifyListeners();

    try {
      final history = await _connectionService.getBillingHistory();
      _billingHistoryResponse = ApiResponse.completed(history);
    } catch (e) {
      _billingHistoryResponse = ApiResponse.error(e.toString());
    }

    notifyListeners();
  }
  Future<bool> confirmPayment(int billId, Map<String, dynamic> paymentDetails) async {
    try {
      // Validate payment details before sending
      if (paymentDetails['payment_id'] == null || paymentDetails['payment_id'].isEmpty) {
        print('Invalid payment ID');
        return false;
      }

      final result = await _connectionService.confirmPayment(billId, paymentDetails);

      if (result != null) {
        // Log successful payment
        print('Payment confirmed successfully for bill $billId');

        // Refresh billing data after successful payment
        await getCurrentBilling();
        await getBillingHistory();
        return true;
      }

      print('Payment confirmation returned null for bill $billId');
      return false;
    } catch (e) {
      // Log the specific error
      print('Payment confirmation error: $e');

      // Optionally, you can add more specific error handling
      if (e is DioException) {
        final errorMessage = e.response?.data['error'] ?? 'Unknown payment error';
        print('Dio Error: $errorMessage');
      }

      return false;
    }
  }  // Set selected package
  void setSelectedPackage(Package package) {
    _selectedPackage = package;
    notifyListeners();
  }

  // Get all connection applications
  Future<void> getConnectionApplications() async {
    _applicationsResponse = ApiResponse.loading();
    notifyListeners();

    try {
      final applications = await _connectionService.getConnectionApplications();
      _applicationsResponse = ApiResponse.completed(applications);
    } catch (e) {
      _applicationsResponse = ApiResponse.error(e.toString());
    }

    notifyListeners();
  }

  // Get a specific connection application
  Future<void> getConnectionApplication(int id) async {
    _applicationResponse = ApiResponse.loading();
    notifyListeners();

    try {
      final application = await _connectionService.getConnectionApplication(id);
      _applicationResponse = ApiResponse.completed(application);
    } catch (e) {
      _applicationResponse = ApiResponse.error(e.toString());
    }

    notifyListeners();
  }

  // Create a new connection application
  Future<void> createConnectionApplication({
    required String fullName,
    required String email,
    required String phone,
    required String address,
  }) async {
    if (_selectedPackage == null) {
      _applicationResponse = ApiResponse.error('No package selected');
      notifyListeners();
      return;
    }

    _applicationResponse = ApiResponse.loading();
    notifyListeners();

    try {
      final request = ConnectionApplicationRequest(
        fullName: fullName,
        email: email,
        phone: phone,
        address: address,
        packageId: _selectedPackage!.id,
      );

      final application = await _connectionService.createConnectionApplication(request);
      _applicationResponse = ApiResponse.completed(application);

      // If successful, refresh the applications list
      if (application != null) {
        await getConnectionApplications();
      }
    } catch (e) {
      _applicationResponse = ApiResponse.error(e.toString());
    }

    notifyListeners();
  }

  // Upload document for a connection application
  Future<void> uploadDocument(
      int applicationId,
      File file,
      String documentType,
      ) async {
    _documentUploadResponse = ApiResponse.loading();
    notifyListeners();

    try {
      final document = await _connectionService.uploadDocument(
        applicationId,
        file,
        documentType,
      );
      _documentUploadResponse = ApiResponse.completed(document);

      // If successful, refresh the application details
      if (document != null) {
        await getConnectionApplication(applicationId);
      }
    } catch (e) {
      _documentUploadResponse = ApiResponse.error(e.toString());
    }

    notifyListeners();
  }

  // Get active connection
// Get active connection
  Future<void> getActiveConnection() async {
    _activeConnectionResponse = ApiResponse.loading();
    notifyListeners();

    try {
      final connection = await _connectionService.getActiveConnection();
      // If we get a connection, completed with data
      // If null, completed with null (will show "No active connections")
      _activeConnectionResponse = ApiResponse.completed(connection);
    } catch (e) {
      print("Error in provider.getActiveConnection: $e");

      // Special handling for the specific 404 error
      if (e.toString().contains('No ActiveConnection matches')) {
        print("Converting 404 to completed(null) response");
        // Treat as "no connection" rather than error
        _activeConnectionResponse = ApiResponse.completed(null);
      } else {
        // For other errors, show error state
        _activeConnectionResponse = ApiResponse.error(e.toString());
      }
    }

    notifyListeners();
  }

  // Get available packages from server
  Future<void> getPackages() async {
    _packagesResponse = ApiResponse.loading();
    notifyListeners();

    try {
      final packages = await _connectionService.getPackages();
      _packagesResponse = ApiResponse.completed(packages);
    } catch (e) {
      _packagesResponse = ApiResponse.error(e.toString());
    }

    notifyListeners();
  }

  // Reset states
  void resetState() {
    _applicationResponse = ApiResponse.completed(null);
    _documentUploadResponse = ApiResponse.completed(null);
    notifyListeners();
  }

}