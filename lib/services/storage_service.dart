import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_constants.dart';
import '../models/user_models.dart';

class StorageService {
  static Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // Save access token
  static Future<bool> saveAccessToken(String token) async {
    final prefs = await _prefs;
    return await prefs.setString(AppConstants.tokenKey, token);
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.tokenKey);
  }

  // Save refresh token
  static Future<bool> saveRefreshToken(String token) async {
    final prefs = await _prefs;
    return await prefs.setString(AppConstants.refreshTokenKey, token);
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.refreshTokenKey);
  }

  // Save user data
  static Future<bool> saveUserData(User user) async {
    final prefs = await _prefs;
    return await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }

  // Get user data
  static Future<User?> getUserData() async {
    final prefs = await _prefs;
    final userData = prefs.getString(AppConstants.userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // Set logged in status
  static Future<bool> setLoggedIn(bool status) async {
    final prefs = await _prefs;
    return await prefs.setBool(AppConstants.isLoggedInKey, status);
  }

  // Get logged in status
  static Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getBool(AppConstants.isLoggedInKey) ?? false;
  }

  // Clear all stored data (for logout)
  static Future<bool> clearAll() async {
    final prefs = await _prefs;
    return await prefs.clear();
  }
}