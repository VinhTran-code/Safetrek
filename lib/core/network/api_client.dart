// lib/core/network/api_client.dart

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiClient {
  final Dio dio;
  final SharedPreferences prefs;

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
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Log request details
          print('📤 REQUEST: ${options.method} ${options.baseUrl}${options.path}');
          print('📝 Headers: ${options.headers}');
          print('📦 Data: ${options.data}');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response
          print('✅ RESPONSE [${response.statusCode}]: ${response.requestOptions.path}');
          print('📥 Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          // Log error details
          print('❌ ERROR [${error.response?.statusCode}]: ${error.requestOptions.path}');
          print('📍 URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}');
          print('📦 Request Data: ${error.requestOptions.data}');
          print('📥 Response Data: ${error.response?.data}');
          print('🔍 Error Message: ${error.message}');

          // Xử lý lỗi 401 (Unauthorized)
          if (error.response?.statusCode == 401) {
            // Clear token và user data
            await prefs.remove(ApiConstants.tokenKey);
            await prefs.remove(ApiConstants.userKey);
            // Có thể redirect về login screen ở đây
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

