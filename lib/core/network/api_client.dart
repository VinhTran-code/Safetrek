// lib/core/network/api_client.dart

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiClient {
  final Dio dio;
  final SharedPreferences prefs;

  // Callback để handle 401 - redirect về login
  Function()? onUnauthorized;

  ApiClient({required this.dio, required this.prefs}) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.options.baseUrl = ApiConstants.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.headers = {
      'Content-Type': ApiConstants.contentType,
      'Accept': ApiConstants.accept,
    };

    // Debug: Show which base URL is being used
    print('🌐 API Client initialized with Base URL: ${ApiConstants.baseUrl}');

    // Interceptor để log request và response
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = prefs.getString(ApiConstants.tokenKey);

          // DEBUG: Check token existence and validity
          if (token == null || token.isEmpty) {
            print('❌ ERROR: No token found in SharedPreferences!');
            print('🔍 Available keys: ${prefs.getKeys()}');
          } else {
            print('🔑 Token found: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Log request details với format rõ ràng
          print('\n========================================');
          print('📤 REQUEST');
          print('   Method: ${options.method}');
          print('   URL: ${options.baseUrl}${options.path}');
          print('   Headers: ${options.headers}');
          if (options.data != null) {
            print('   Body: ${options.data}');
          }
          if (options.queryParameters.isNotEmpty) {
            print('   Query: ${options.queryParameters}');
          }
          print('========================================\n');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response với format rõ ràng
          print('\n========================================');
          print('✅ RESPONSE');
          print('   Status: ${response.statusCode}');
          print('   Path: ${response.requestOptions.path}');
          print('   Data: ${response.data}');
          print('========================================\n');
          return handler.next(response);
        },
        onError: (error, handler) async {
          // Log error details với format rõ ràng
          print('\n========================================');
          print('❌ ERROR');
          print('   Status: ${error.response?.statusCode}');
          print('   Method: ${error.requestOptions.method}');
          print('   URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}');
          if (error.requestOptions.data != null) {
            print('   Request Body: ${error.requestOptions.data}');
          }
          if (error.response?.data != null) {
            print('   Response Data: ${error.response?.data}');
          }
          print('   Error Message: ${error.message}');
          print('========================================\n');

          // Xử lý lỗi 401 (Unauthorized - Session Expired)
          if (error.response?.statusCode == 401) {
            // Clear token và user data
            await prefs.remove(ApiConstants.tokenKey);
            await prefs.remove(ApiConstants.userKey);
            print('⚠️ Token cleared due to 401 error. User needs to login again.');

            // Trigger callback để app redirect về login
            if (onUnauthorized != null) {
              print('🔄 Triggering onUnauthorized callback...');
              onUnauthorized!();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await dio.put(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) async {
    return await dio.delete(path, data: data);
  }
}

