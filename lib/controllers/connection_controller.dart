import 'dart:io';
import '../models/api_response.dart';

import '../models/connection_models.dart';
import '../models/pacakge_models.dart';
import '../services/connection_service.dart';

class ConnectionController {
  final ConnectionService _connectionService = ConnectionService();

  // Get all connection applications
  Future<ApiResponse<List<ConnectionApplication>>> getConnectionApplications() async {
    try {
      final applications = await _connectionService.getConnectionApplications();
      return ApiResponse.completed(applications);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // Get a specific connection application
  Future<ApiResponse<ConnectionApplication?>> getConnectionApplication(int id) async {
    try {
      final application = await _connectionService.getConnectionApplication(id);
      return ApiResponse.completed(application);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // Create a new connection application
  Future<ApiResponse<ConnectionApplication?>> createConnectionApplication({
    required String fullName,
    required String email,
    required String phone,
    required String address,
    required int packageId,
  }) async {
    try {
      final request = ConnectionApplicationRequest(
        fullName: fullName,
        email: email,
        phone: phone,
        address: address,
        packageId: packageId,
      );

      final application = await _connectionService.createConnectionApplication(request);
      return ApiResponse.completed(application);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // Upload document for a connection application
  Future<ApiResponse<ApplicationDocument?>> uploadDocument(
      int applicationId,
      File file,
      String documentType,
      ) async {
    try {
      final document = await _connectionService.uploadDocument(
        applicationId,
        file,
        documentType,
      );
      return ApiResponse.completed(document);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // Get active connection
  Future<ApiResponse<ConnectionApplication?>> getActiveConnection() async {
    try {
      final connection = await _connectionService.getActiveConnection();
      return ApiResponse.completed(connection);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // Get available packages
  Future<ApiResponse<List<Package>>> getPackages() async {
    try {
      final packages = await _connectionService.getPackages();
      return ApiResponse.completed(packages);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}