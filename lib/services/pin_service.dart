// lib/services/pin_service.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/user.dart';

class PinService {
  final ApiClient apiClient;
  final SharedPreferences prefs;

  PinService({required this.apiClient, required this.prefs});

  /// Setup PINs - Gọi API POST /setup-pins
  /// Cài đặt Safety PIN và Duress PIN (chỉ làm 1 lần sau khi register)
  Future<void> setupPins({
    required String safetyPin,
    required String duressPin,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.setupPins,
        data: {
          'safety_pin': safetyPin,
          'duress_pin': duressPin,
        },
      );

      // Response thành công sẽ có dạng:
      // {
      //   "success": true,
      //   "message": "PINs setup successful"
      // }

      if (response.data['success'] != true) {
        throw Exception('Failed to setup PINs');
      }

      // Sau khi setup thành công, cập nhật user info để có is_pin_setup = true
      await _refreshUserData();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Refresh user data từ server để cập nhật trạng thái is_pin_setup
  Future<void> _refreshUserData() async {
    try {
      final response = await apiClient.get(ApiConstants.me);
      final user = UserModel.fromJson(response.data['data'] as Map<String, dynamic>);

      // Cập nhật user trong storage
      await prefs.setString(ApiConstants.userKey, json.encode(user.toJson()));
    } catch (e) {
      // Nếu lỗi khi refresh, không throw để không ảnh hưởng flow chính
      print('Error refreshing user data: $e');
    }
  }

  /// Verify Safety PIN - Gọi API POST /verify-safety-pin
  /// Xác thực mã PIN an toàn người dùng nhập
  Future<void> verifySafetyPin(String pin) async {
    try {
      // Chúng ta sẽ cần tạo API endpoint này ở phía server
      final response = await apiClient.post(
        '/verify-safety-pin', // <-- Endpoint mới
        data: {
          'safety_pin': pin,
        },
      );

      // Nếu server trả về success != true, coi như là lỗi
      if (response.data['success'] != true) {
        throw Exception('Phản hồi không hợp lệ từ server.');
      }

      // Nếu không có lỗi, hàm sẽ kết thúc và coi như thành công
      // Nếu PIN sai, server nên trả về lỗi (ví dụ 422) và Dio sẽ tự động coi đó là một Exception
    } on DioException catch (e) {
      // Ném lại lỗi đã được xử lý để UI có thể hiển thị
      throw _handleError(e);
    }
  }

  /// Xử lý lỗi từ API
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
}

