import 'dart:convert';
import '../config/api_endpoints.dart';
import '../models/user_models.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Register a new user
  Future<bool> register(RegisterRequest request) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );

      return response != null;
    } catch (e) {
      rethrow;
    }
  }

  // Login user
  Future<bool> login(AuthRequest request) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      if (response != null) {
        final authResponse = AuthResponse.fromJson(response);

        // Save to shared preferences
        await StorageService.saveAccessToken(authResponse.accessToken);
        await StorageService.saveRefreshToken(authResponse.refreshToken);
        await StorageService.saveUserData(authResponse.user);
        await StorageService.setLoggedIn(true);

        return true;
      }

      return false;
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final isLoggedIn = await StorageService.isLoggedIn();
      final token = await StorageService.getAccessToken();

      // If we have both the flag and a token, consider the user logged in
      return isLoggedIn && token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Logout user
  Future<bool> logout() async {
    try {
      await StorageService.clearAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      return await StorageService.getUserData();
    } catch (e) {
      return null;
    }
  }
}