// lib/repositories/trip_repository.dart
import 'package:safetrek_app/core/network/api_client.dart';
import 'package:safetrek_app/models/trip.dart';
import 'package:safetrek_app/core/constants/api_constants.dart';

class TripRepository {
  final ApiClient apiClient;

  TripRepository({required this.apiClient});

  /// Bắt đầu chuyến đi mới
  Future<Trip> startTrip(StartTripRequest request) async {
    try {
      final response = await apiClient.post(
        ApiConstants.startTrip,
        data: request.toJson(),
      );

      // API trả về: { "success": true, "data": { "trip": {...}, "time_remaining_minutes": 15 } }
      return Trip.fromJson(response.data['data']['trip']);
    } catch (e) {
      print('Lỗi khi bắt đầu chuyến đi: $e');
      rethrow;
    }
  }

  /// Gửi cảnh báo khẩn cấp (Panic Button)
  Future<Map<String, dynamic>> sendPanic(PanicRequest request) async {
    try {
      final response = await apiClient.post(
        ApiConstants.panic,
        data: request.toJson(),
      );

      // API trả về: { "success": true, "data": { "trip_id": 2, "alert_sent_at": "..." } }
      return response.data['data'];
    } catch (e) {
      print('Lỗi khi gửi cảnh báo khẩn cấp: $e');
      rethrow;
    }
  }

  /// Cập nhật vị trí trong chuyến đi
  Future<void> updateLocation(UpdateLocationRequest request) async {
    try {
      await apiClient.post(
        ApiConstants.updateLocation,
        data: request.toJson(),
      );
    } catch (e) {
      print('Lỗi khi cập nhật vị trí: $e');
      rethrow;
    }
  }

  /// Kết thúc chuyến đi bằng PIN
  Future<Map<String, dynamic>> endTrip(EndTripRequest request) async {
    try {
      final response = await apiClient.post(
        ApiConstants.endTrip,
        data: request.toJson(),
      );

      // API trả về: { "success": true, "message": "...", "data": { "trip_id": 1, "ended_at": "..." } }
      return {
        'message': response.data['message'],
        'data': response.data['data'],
      };
    } catch (e) {
      print('Lỗi khi kết thúc chuyến đi: $e');
      rethrow;
    }
  }

  /// Kết thúc chuyến đi bằng PIN với location và battery level
  /// Backend sẽ tự động xử lý:
  /// - Safety PIN: Kết thúc bình thường
  /// - Duress PIN: Gửi duress alert với location và battery
  Future<Map<String, dynamic>> endTripWithLocation(EndTripWithLocationRequest request) async {
    try {
      final response = await apiClient.post(
        ApiConstants.endTrip,
        data: request.toJson(),
      );

      // API trả về: { "success": true, "message": "...", "data": { "trip_id": 1, "ended_at": "..." } }
      return {
        'message': response.data['message'],
        'data': response.data['data'],
      };
    } catch (e) {
      print('Lỗi khi kết thúc chuyến đi với location: $e');
      rethrow;
    }
  }

  /// Hủy chuyến đi
  Future<void> cancelTrip(int tripId) async {
    try {
      await apiClient.post(
        ApiConstants.cancelTrip,
        data: {'trip_id': tripId},
      );
    } catch (e) {
      print('Lỗi khi hủy chuyến đi: $e');
      rethrow;
    }
  }

  /// Lấy chuyến đi đang hoạt động
  Future<Trip?> getActiveTrip() async {
    try {
      final response = await apiClient.get(ApiConstants.getActiveTrip);

      if (response.data['data'] != null) {
        return Trip.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy chuyến đi đang hoạt động: $e');
      rethrow;
    }
  }

  /// Lấy lịch sử chuyến đi
  Future<List<Trip>> getTripHistory({int page = 1}) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.getTripHistory}?page=$page',
      );

      // API trả về pagination: { "data": { "data": [...], "current_page": 1, ... } }
      final List<dynamic> trips = response.data['data']['data'];
      return trips.map((json) => Trip.fromJson(json)).toList();
    } catch (e) {
      print('Lỗi khi lấy lịch sử chuyến đi: $e');
      rethrow;
    }
  }

  /// Xác thực PIN (để biết là Safety hay Duress PIN)
  Future<String> verifyTripPin(String pin) async {
    try {
      final response = await apiClient.post(
        ApiConstants.verifyTripPin,
        data: {'pin': pin},
      );

      // API trả về: { "success": true, "data": { "pin_type": "safety" } }
      return response.data['data']['pin_type'] as String; // "safety" hoặc "duress"
    } catch (e) {
      print('Lỗi khi xác thực PIN: $e');
      rethrow;
    }
  }
}

