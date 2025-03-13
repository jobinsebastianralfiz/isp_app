import '../models/api_response.dart';
import '../models/user_models.dart';
import '../services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  // Register a new user
  Future<ApiResponse<bool>> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String address,
  }) async {
    try {
      final request = RegisterRequest(
        username: username,
        email: email,
        password: password,
        password2: confirmPassword,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        address: address,
      );

      final result = await _authService.register(request);
      return ApiResponse.completed(result);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // Login user
  Future<ApiResponse<bool>> login({
    required String username,
    required String password,
  }) async {
    try {
      final request = AuthRequest(
        username: username,
        password: password,
      );

      final result = await _authService.login(request);
      return ApiResponse.completed(result);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _authService.isLoggedIn();
  }

  // Logout user
  Future<ApiResponse<bool>> logout() async {
    try {
      final result = await _authService.logout();
      return ApiResponse.completed(result);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // Get current user
  Future<ApiResponse<User?>> getCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      return ApiResponse.completed(user);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}