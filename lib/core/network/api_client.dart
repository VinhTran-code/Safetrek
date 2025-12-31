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

    print('🌐 API Client initialized with Base URL: ${ApiConstants.baseUrl}');

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          print('--- Interceptor: Bắt đầu Request ---');
          print('🚀 Path: ${options.path}');
          
          final token = prefs.getString(ApiConstants.tokenKey);

          if (token != null) {
            print('🔑 Token tìm thấy! Đang đính kèm vào header.');
            // print('   Token: $token'); // Uncomment dòng này nếu muốn xem toàn bộ token
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            print('❌ Không tìm thấy token trong SharedPreferences.');
          }
          
          print('--- Interceptor: Gửi Request đi ---');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ Phản hồi nhận được cho: ${response.requestOptions.path} | Status: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          print('--- Interceptor: Gặp lỗi ---');
          print('💥 Lỗi cho request: ${error.requestOptions.path}');
          print('💥 Status Code: ${error.response?.statusCode}');
          print('💥 Message: ${error.message}');
          
          if (error.response?.statusCode == 401) {
            print('🔴 Lỗi 401 (Unauthorized)! Đang xóa token và dữ liệu người dùng.');
            await prefs.remove(ApiConstants.tokenKey);
            await prefs.remove(ApiConstants.userKey);
          }
          
          print('--- Interceptor: Chuyển lỗi đi tiếp ---');
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
