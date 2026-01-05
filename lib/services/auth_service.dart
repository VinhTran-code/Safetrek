// lib/services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../models/auth_response.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

class AuthService {
  final ApiClient apiClient;
  final SharedPreferences prefs;

  AuthService({required this.apiClient, required this.prefs});

  User? _currentUser;
  User? get currentUser => _currentUser;

  String? _token;
  String? get token => _token;

  // Khởi tạo - Load user và token từ storage
  Future<void> init() async {
    _token = prefs.getString(ApiConstants.tokenKey);
    final userJson = prefs.getString(ApiConstants.userKey);

    if (userJson != null) {
      try {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        _currentUser = UserModel.fromJson(userMap);
      } catch (e) {
        print('Error loading user from storage: $e');
        await clearAuth();
      }
    }
  }

  // Đăng ký
  Future<User> register({
    required String fullName,
    required String phoneNumber,
    String? email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final request = RegisterRequest(
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      print('📤 Sending register request to: ${ApiConstants.baseUrl}${ApiConstants.register}');
      print('📦 Request body: ${request.toJson()}');

      final response = await apiClient.post(
        ApiConstants.register,
        data: request.toJson(),
      );

      print('📥 Register response status: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      final authResponse = AuthResponse.fromJson(response.data);

      // KHÔNG lưu token và user sau khi đăng ký
      // User phải đăng nhập lại để vào app
      // await _saveAuth(authResponse.token, authResponse.user);

      return authResponse.user;
    } on DioException catch (e) {
      print('❌ DioException during register: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      throw _handleError(e);
    } catch (e, stackTrace) {
      print('❌ Unexpected error during register: $e');
      print('📍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Đăng nhập
  Future<User> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final request = LoginRequest(
        phoneNumber: phoneNumber,
        password: password,
      );

      final response = await apiClient.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // Lưu token và user
      await _saveAuth(authResponse.token, authResponse.user);

      return authResponse.user;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Lấy thông tin user hiện tại từ server
  Future<User> getCurrentUser() async {
    try {
      final response = await apiClient.get(ApiConstants.me);

      final user = UserModel.fromJson(response.data['data'] as Map<String, dynamic>);

      // Cập nhật user trong storage
      await prefs.setString(ApiConstants.userKey, json.encode(user.toJson()));
      _currentUser = user;

      return user;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    try {
      await apiClient.post(ApiConstants.logout);
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await clearAuth();
    }
  }

  // Lưu token và user vào storage
  Future<void> _saveAuth(String token, UserModel user) async {
    _token = token;
    _currentUser = user;

    await prefs.setString(ApiConstants.tokenKey, token);
    await prefs.setString(ApiConstants.userKey, json.encode(user.toJson()));

    // DEBUG: Verify token was saved
    final savedToken = prefs.getString(ApiConstants.tokenKey);
    if (savedToken != null && savedToken == token) {
      print('✅ Token saved successfully: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
    } else {
      print('❌ ERROR: Token was NOT saved correctly!');
    }
  }

  // Xóa thông tin auth
  Future<void> clearAuth() async {
    _token = null;
    _currentUser = null;

    await prefs.remove(ApiConstants.tokenKey);
    await prefs.remove(ApiConstants.userKey);
  }

  // Kiểm tra trạng thái đăng nhập
  Future<bool> checkLoginStatus() async {
    return _token != null && _currentUser != null;
  }

  // Xử lý lỗi từ API
  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;

      // Lỗi validation từ Laravel
      if (data is Map && data.containsKey('message')) {
        return data['message'] as String;
      }

      // Lỗi khác
      return 'Có lỗi xảy ra: ${error.response?.statusCode}';
    }

    // Lỗi mạng
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Kết nối bị timeout. Vui lòng thử lại.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
    }

    return 'Có lỗi xảy ra: ${error.message}';
  }

  // Các hàm cũ (giữ lại để tương thích)
  Future<void> forgotPassword(String email) async {
    // TODO: Implement khi có API
    await Future.delayed(const Duration(seconds: 2));
    throw UnimplementedError('Chức năng này chưa được triển khai');
  }

  Future<void> resetPassword(String email, String newPassword) async {
    // TODO: Implement khi có API
    await Future.delayed(const Duration(seconds: 2));
    throw UnimplementedError('Chức năng này chưa được triển khai');
  }
}