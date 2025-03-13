import 'dart:io';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:ispmanagement/models/active_connection.dart';
import 'package:ispmanagement/models/billing_model.dart';
import '../config/api_endpoints.dart';
import '../models/connection_models.dart';
import '../models/pacakge_models.dart';
import '../services/api_service.dart';
import '../services/package_service.dart';

class ConnectionService {
  final ApiService _apiService = ApiService();
  final PackageService _packageService = PackageService();

  // Get all connection applications for the current user
  Future<List<ConnectionApplication>> getConnectionApplications() async {
    try {
      final response = await _apiService.get(ApiEndpoints.connections);

      if (response != null) {
        // Check if the response is paginated (has a 'results' key)
        if (response is Map && response.containsKey('results')) {
          final List<ConnectionApplication> applications = (response['results'] as List)
              .map((item) => ConnectionApplication.fromJson(item))
              .toList();
          return applications;
        }
        // If it's a direct list
        else if (response is List) {
          final List<ConnectionApplication> applications = response
              .map((item) => ConnectionApplication.fromJson(item))
              .toList();
          return applications;
        }
      }

      return [];
    } catch (e) {
      log('Error getting connection applications: $e');
      rethrow;
    }
  }

  // Get a specific connection application
  Future<ConnectionApplication?> getConnectionApplication(int id) async {
    try {
      final response = await _apiService.get('${ApiEndpoints.connections}$id/');

      if (response != null) {
        return ConnectionApplication.fromJson(response);
      }

      return null;
    } catch (e) {
      log('Error getting connection application: $e');
      rethrow;
    }
  }

  // Create a new connection application
  Future<ConnectionApplication?> createConnectionApplication(
      ConnectionApplicationRequest request
      ) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.connections,
        data: request.toJson(),
      );

      if (response != null) {
        return ConnectionApplication.fromJson(response);
      }

      return null;
    } catch (e) {
      log('Error creating connection application: $e');
      rethrow;
    }
  }

  // Upload document for a connection application
  Future<ApplicationDocument?> uploadDocument(
      int applicationId,
      File file,
      String documentType,
      ) async
  {
    try {
      final fileName = file.path.split('/').last;

      // Create form data
      final formData = FormData.fromMap({
        'document_type': documentType,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final url = ApiEndpoints.getUrlWithPathParam(
        ApiEndpoints.uploadDocument,
        'id',
        applicationId.toString(),
      );

      final response = await _apiService.postFormData(
        url,
        formData,
      );

      if (response != null) {
        return ApplicationDocument.fromJson(response);
      }

      return null;
    } catch (e) {
      log('Error uploading document: $e');
      rethrow;
    }
  }

// Update the imports at the top of connection_service.dart

// Then update the getActiveConnection method
  Future<ConnectionApplication?> getActiveConnection() async {
    try {
      print("Fetching active connection...");

      // First try to get an ActiveConnection
      try {
        final response = await _apiService.get(ApiEndpoints.activeConnection);
        print("Active connection response: $response");

        if (response != null) {
          // Parse as ActiveConnection and convert to ConnectionApplication
          final activeConnection = ActiveConnection.fromJson(response);
          final connection = activeConnection.toConnectionApplication();

          print("Successfully parsed ActiveConnection: ${activeConnection.id}");
          print("Converted to ConnectionApplication: ${connection.id}");

          return connection;
        }
      } catch (e) {
        print("Error getting active connection: $e");

        // If it's a 404 error, try to get the connection application instead
        if (e is DioException && e.response?.statusCode == 404) {
          print("No active connection found, trying to get connection application...");

          try {
            final response = await _apiService.get(ApiEndpoints.userConnectionApplication);
            print("Connection application response: $response");

            if (response != null) {
              // Parse directly as ConnectionApplication
              final connection = ConnectionApplication.fromJson(response);

              // If the package object is null, try to fetch it
              if (connection.package == null && connection.packageId > 0) {
                // ... package fetching code
              }

              return connection;
            }
          } catch (appError) {
            print("Error getting connection application: $appError");
          }
        } else {
          // For other errors, rethrow
          rethrow;
        }
      }

      print("No active connection or application found");
      return null;
    } catch (e) {
      print("Error in getActiveConnection: $e");
      rethrow;
    }
  }

  // Helper method to attach package details to a connection
  Future<ConnectionApplication> _attachPackageDetails(ConnectionApplication connection) async {
    try {
      print("Fetching package details for ID: ${connection.packageId}");

      // Get all packages
      final packages = await getPackages();
      print("Fetched ${packages.length} packages");

      // Find the package that matches our packageId
      Package? matchingPackage;
      try {
        matchingPackage = packages.firstWhere(
              (p) => p.id == connection.packageId,
        );
        print("Found matching package: ${matchingPackage.name}");
      } catch (e) {
        print("No matching package found: $e");
        matchingPackage = null;
      }

      if (matchingPackage != null) {
        // Create a new connection with the package details
        return ConnectionApplication(
          id: connection.id,
          status: connection.status,
          fullName: connection.fullName,
          email: connection.email,
          phone: connection.phone,
          address: connection.address,
          packageId: connection.packageId,
          packageName: connection.packageName ?? matchingPackage.name,
          createdAt: connection.createdAt,
          updatedAt: connection.updatedAt,
          notes: connection.notes,
          installationDate: connection.installationDate,
          installationCompletedDate: connection.installationCompletedDate,
          documents: connection.documents,
          connectionNumber: connection.connectionNumber,
          package: matchingPackage,
        );
      }

      return connection;
    } catch (e) {
      print("Error fetching package details: $e");
      return connection;
    }
  }

  // Get available packages from the server API
  Future<List<Package>> getPackages() async {
    try {
      // Use the package service to get packages from the API
      return await _packageService.getPackages();
    } catch (e) {
      log('Error in connection service - getPackages: $e');

      // Return fallback packages wrapped in a Future
      log('Returning fallback packages due to API error');
      return Future.value(_getFallbackPackages());
    }
  }

  // Fallback packages in case the API call fails
  List<Package> _getFallbackPackages() {
    return [
      Package(
        id: 1,
        name: 'Basic Plan',
        description: 'Perfect for light browsing and email',
        price: 999,
        speed: '10 Mbps',
        features: ['Unlimited data', '24/7 support', 'No setup fee'],
        validity: '30 days',
      ),
      Package(
        id: 2,
        name: 'Standard Plan',
        description: 'Great for streaming and working from home',
        price: 1499,
        speed: '50 Mbps',
        features: ['Unlimited data', '24/7 priority support', 'Free router', 'No setup fee'],
        validity: '30 days',
      ),
      Package(
        id: 3,
        name: 'Premium Plan',
        description: 'Ultimate experience for heavy users',
        price: 1999,
        speed: '100 Mbps',
        features: ['Unlimited data', '24/7 priority support', 'Free high-performance router', 'Static IP address', 'No setup fee'],
        validity: '30 days',
      ),
    ];
  }


// Add this method to your existing ConnectionService class

// Get current billing information
  Future<MonthlyBilling?> getCurrentBilling() async {
    try {
      final response = await _apiService.get(ApiEndpoints.currentBilling);

      if (response != null) {
        return MonthlyBilling.fromJson(response);
      }

      return null;
    } catch (e) {
      log('Error getting current billing: $e');
      rethrow;
    }
  }

// Get billing history
  Future<List<MonthlyBilling>> getBillingHistory() async {
    try {
      final response = await _apiService.get(ApiEndpoints.billing);

      if (response != null) {
        if (response is List) {
          return response
              .map((item) => MonthlyBilling.fromJson(item))
              .toList();
        } else if (response is Map && response.containsKey('results')) {
          return (response['results'] as List)
              .map((item) => MonthlyBilling.fromJson(item))
              .toList();
        }
      }

      return [];
    } catch (e) {
      log('Error getting billing history: $e');
      rethrow;
    }
  }

// Confirm payment for a bill
// Add this method to your existing ConnectionService class
  Future<bool> confirmPayment(int billId, Map<String, dynamic> paymentDetails) async {
    try {
      // Ensure all fields are present and non-null
      final sanitizedPaymentDetails = {
        'payment_id': (paymentDetails['payment_id'] ?? '').toString().trim(),
        'order_id': (paymentDetails['order_id'] ?? billId.toString()).toString().trim(),
        'signature': (paymentDetails['signature'] ?? 'no_signature').toString().trim(),
      };

      // Log the payment details for debugging
      print('Confirm Payment Request:');
      print('Bill ID: $billId');
      print('Payment Details: $sanitizedPaymentDetails');

      final url = ApiEndpoints.getUrlWithPathParam(
          ApiEndpoints.confirmPayment,
          'id',
          billId.toString()
      );

      final response = await _apiService.post(
        url,
        data: sanitizedPaymentDetails,
      );

      // Log the response
      print('Confirm Payment Response: $response');

      // Return true if response is not null
      return response != null;
    } catch (e) {
      // Detailed error logging
      print('Payment Confirmation Error:');
      print('Bill ID: $billId');
      print('Error: $e');

      // Rethrow the error to allow caller to handle it
      rethrow;
    }
  }
}