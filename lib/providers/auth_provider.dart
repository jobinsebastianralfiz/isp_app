import 'package:flutter/material.dart';
import '../models/api_response.dart';
import '../controllers/auth_controller.dart';
import '../models/user_models.dart';

class AuthProvider extends ChangeNotifier {
  final AuthController _authController = AuthController();

  ApiResponse<bool> _registerResponse = ApiResponse.completed(false);
  ApiResponse<bool> _loginResponse = ApiResponse.completed(false);
  ApiResponse<User?> _userResponse = ApiResponse.completed(null);
  bool _isLoggedIn = false;

  // Getters
  ApiResponse<bool> get registerResponse => _registerResponse;
  ApiResponse<bool> get loginResponse => _loginResponse;
  ApiResponse<User?> get userResponse => _userResponse;
  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _userResponse.data;
  bool get isLoading => _registerResponse.isLoading || _loginResponse.isLoading || _userResponse.isLoading;

  // Initialize - check login status and get user
  Future<void> initialize() async {
    _isLoggedIn = await _authController.isLoggedIn();
    if (_isLoggedIn) {
      await getCurrentUser();
    }
    notifyListeners();
  }

  // Register user
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String address,
  }) async {
    _registerResponse = ApiResponse.loading();
    notifyListeners();

    _registerResponse = await _authController.register(
      username: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      address: address,
    );

    notifyListeners();
  }

  // Login user
  Future<void> login({
    required String username,
    required String password,
  }) async {
    _loginResponse = ApiResponse.loading();
    notifyListeners();

    _loginResponse = await _authController.login(
      username: username,
      password: password,
    );

    if (_loginResponse.isCompleted && _loginResponse.data == true) {
      _isLoggedIn = true;
      await getCurrentUser();
    }

    notifyListeners();
  }

  // Get current user
  Future<void> getCurrentUser() async {
    _userResponse = ApiResponse.loading();
    notifyListeners();

    _userResponse = await _authController.getCurrentUser();

    notifyListeners();
  }

  // Logout user
  Future<void> logout() async {
    await _authController.logout();
    _isLoggedIn = false;
    _userResponse = ApiResponse.completed(null);

    notifyListeners();
  }

  // Reset login status
  void resetStatus() {
    _loginResponse = ApiResponse.completed(false);
    _registerResponse = ApiResponse.completed(false);
    notifyListeners();
  }
}