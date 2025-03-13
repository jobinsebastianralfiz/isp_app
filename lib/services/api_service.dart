import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../config/api_endpoints.dart';

class ApiService {
  late Dio _dio;
  final bool enableDebugLogs;

  ApiService({this.enableDebugLogs = true}) {
    _dio = Dio();
    _dio.options.baseUrl = ApiEndpoints.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);  // Increased timeout for local dev
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.contentType = 'application/json';
    _dio.options.responseType = ResponseType.json;

    // Add logging interceptor for debug mode
    if (enableDebugLogs) {
      _dio.interceptors.add(
        LogInterceptor(
            requestBody: true,
            responseBody: true,
            logPrint: (log) {
              dev.log('DIO LOG: $log');
            }
        ),
      );
    }

    // Add interceptor for auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          _logRequest(options);
          final token = await StorageService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse(response);
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          _logError(error);
          if (error.response?.statusCode == 401) {
            // Token expired, attempt to refresh
            if (await _refreshToken()) {
              // Retry the original request
              return handler.resolve(await _retry(error.requestOptions));
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // GET request
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      dev.log('Making GET request to: ${ApiEndpoints.baseUrl}$endpoint');
      final Response response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  // POST request
  Future<dynamic> post(String endpoint, {dynamic data}) async {
    try {
      // Convert to json string if data is a Map
      final requestData = data is Map ? jsonEncode(data) : data;
      dev.log('Making POST request to: ${ApiEndpoints.baseUrl}$endpoint');
      dev.log('Request data: $requestData');

      final Response response = await _dio.post(
        endpoint,
        data: requestData,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  // POST request with FormData (for file uploads)
  Future<dynamic> postFormData(String endpoint, FormData formData) async {
    try {
      dev.log('Making POST FormData request to: ${ApiEndpoints.baseUrl}$endpoint');
      final Response response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }
  Future<dynamic> patch(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.patch(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }
  // PUT request
  Future<dynamic> put(String endpoint, {dynamic data}) async {
    try {
      dev.log('Making PUT request to: ${ApiEndpoints.baseUrl}$endpoint');
      final Response response = await _dio.put(
        endpoint,
        data: data is String ? data : jsonEncode(data),
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  // DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      dev.log('Making DELETE request to: ${ApiEndpoints.baseUrl}$endpoint');
      final Response response = await _dio.delete(endpoint);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  // Test connection to server
  Future<bool> testConnection() async {
    try {
      // Try to connect to the Django admin page as a simple test
      dev.log('Testing connection to: ${ApiEndpoints.baseUrl}');
      final response = await _dio.get('/admin/',
          options: Options(validateStatus: (status) => true)
      );
      dev.log('Connection test status code: ${response.statusCode}');
      // Any response means we could connect (even a 404 is fine for testing)
      return response.statusCode != null;
    } catch (e) {
      dev.log('Connection test failed: $e');
      return false;
    }
  }

  // Refresh token and retry request
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      // Implement your token refresh logic here
      // For example:
      // final response = await _dio.post('/api/token/refresh/', data: {'refresh': refreshToken});
      // await StorageService.saveAccessToken(response.data['access']);
      // return true;

      // Temporary placeholder
      return false;
    } catch (e) {
      return false;
    }
  }

  // Retry the original request with new token
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // Handle DioError
  void _handleError(DioException error) {
    String errorDescription = "An error occurred";

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorDescription = "Connection timeout";
        break;
      case DioExceptionType.sendTimeout:
        errorDescription = "Send timeout";
        break;
      case DioExceptionType.receiveTimeout:
        errorDescription = "Receive timeout";
        break;
      case DioExceptionType.badResponse:
        errorDescription = _handleResponseError(error.response!);
        break;
      case DioExceptionType.cancel:
        errorDescription = "Request was cancelled";
        break;
      case DioExceptionType.connectionError:
        errorDescription = "Connection error: ${error.message}";
        break;
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          SocketException socketError = error.error as SocketException;
          errorDescription = "Network error: ${socketError.message}";
        } else {
          errorDescription = "Unexpected error: ${error.message}";
        }
        break;
      default:
        errorDescription = "Something went wrong: ${error.message}";
        break;
    }

    dev.log('ERROR: $errorDescription');
    throw errorDescription;
  }

  // Handle response error
  String _handleResponseError(Response response) {
    String errorMessage = "Error: ${response.statusCode}";

    final statusCode = response.statusCode;
    final data = response.data;

    dev.log('Response error data: $data');

    if (data != null && data is Map<String, dynamic>) {
      // Try to extract error message from various formats Django might return
      if (data.containsKey('detail')) {
        errorMessage = data['detail'];
      } else if (data.containsKey('message')) {
        errorMessage = data['message'];
      } else if (data.containsKey('error')) {
        errorMessage = data['error'];
      } else if (data.containsKey('non_field_errors')) {
        // Django REST framework often returns validation errors here
        final errors = data['non_field_errors'];
        if (errors is List && errors.isNotEmpty) {
          errorMessage = errors.first.toString();
        }
      } else {
        // Check for field-specific errors
        final fieldErrors = <String>[];
        data.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            fieldErrors.add('$key: ${value.first}');
          } else if (value is String) {
            fieldErrors.add('$key: $value');
          }
        });

        if (fieldErrors.isNotEmpty) {
          errorMessage = fieldErrors.join(', ');
        }
      }
    }

    // Add HTTP status context for debugging
    switch (statusCode) {
      case 400:
        return 'Bad request: $errorMessage';
      case 401:
        return 'Unauthorized: $errorMessage';
      case 403:
        return 'Forbidden: $errorMessage';
      case 404:
        return 'Not found: $errorMessage';
      case 500:
        return 'Server error: $errorMessage';
      default:
        return errorMessage;
    }
  }

  // Debug logging methods
  void _logRequest(RequestOptions options) {
    if (!enableDebugLogs) return;

    dev.log('╔══════════════════════════ REQUEST ══════════════════════════');
    dev.log('║ METHOD: ${options.method}');
    dev.log('║ URL: ${options.baseUrl}${options.path}');
    dev.log('║ HEADERS: ${options.headers}');

    if (options.queryParameters.isNotEmpty) {
      dev.log('║ QUERY: ${options.queryParameters}');
    }

    if (options.data != null) {
      dev.log('║ BODY: ${options.data}');
    }

    dev.log('╚═════════════════════════════════════════════════════════════');
  }

  void _logResponse(Response response) {
    if (!enableDebugLogs) return;

    dev.log('╔══════════════════════════ RESPONSE ═════════════════════════');
    dev.log('║ STATUS: ${response.statusCode}');
    dev.log('║ URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}');

    if (response.data != null) {
      dev.log('║ BODY: ${response.data}');
    }

    dev.log('╚═════════════════════════════════════════════════════════════');
  }

  void _logError(DioException error) {
    if (!enableDebugLogs) return;

    dev.log('╔══════════════════════════ ERROR ════════════════════════════');
    dev.log('║ TYPE: ${error.type}');
    dev.log('║ MESSAGE: ${error.message}');
    dev.log('║ URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}');

    if (error.response != null) {
      dev.log('║ STATUS: ${error.response?.statusCode}');
      dev.log('║ BODY: ${error.response?.data}');
    }

    dev.log('╚═════════════════════════════════════════════════════════════');
  }
}