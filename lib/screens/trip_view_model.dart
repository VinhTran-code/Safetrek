// lib/screens/trip_view_model.dart
import 'package:flutter/material.dart';
import 'package:safetrek_app/models/trip.dart';
import 'package:safetrek_app/services/trip_service.dart';

/// Các trạng thái của Trip
abstract class TripState {}

class TripInitial extends TripState {}

class TripLoading extends TripState {}

class TripActive extends TripState {
  final Trip trip;
  final int timeRemainingMinutes;

  TripActive({required this.trip, required this.timeRemainingMinutes});
}

class TripEnded extends TripState {
  final String message;

  TripEnded({required this.message});
}

class TripError extends TripState {
  final String message;

  TripError({required this.message});
}

class TripExpired extends TripState {}

/// ViewModel quản lý state cho Trip
class TripViewModel extends ChangeNotifier {
  final TripService tripService;

  TripViewModel({required this.tripService}) {
    // Đăng ký các callback
    tripService.onTimeUpdate = _handleTimeUpdate;
    tripService.onTripExpired = _handleTripExpired;
    tripService.onTripStateChanged = _handleTripStateChanged;

    // Khởi tạo
    _initTrip();
  }

  TripState _state = TripInitial();
  TripState get state => _state;

  Trip? get currentTrip => tripService.currentTrip;

  int _timeRemaining = 0;
  int get timeRemaining => _timeRemaining;

  /// Khởi tạo - Kiểm tra chuyến đi đang hoạt động
  Future<void> _initTrip() async {
    try {
      await tripService.init();
      if (tripService.currentTrip != null) {
        _timeRemaining = tripService.currentTrip!.getTimeRemainingMinutes();
        _state = TripActive(
          trip: tripService.currentTrip!,
          timeRemainingMinutes: _timeRemaining,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Lỗi khi khởi tạo trip: $e');
    }
  }

  /// Bắt đầu chuyến đi
  Future<void> startTrip({
    required String destinationName,
    required int durationMinutes,
  }) async {
    _state = TripLoading();
    notifyListeners();

    try {
      final trip = await tripService.startTrip(
        destinationName: destinationName,
        durationMinutes: durationMinutes,
      );

      _timeRemaining = trip.getTimeRemainingMinutes();
      _state = TripActive(
        trip: trip,
        timeRemainingMinutes: _timeRemaining,
      );
    } catch (e) {
      _state = TripError(message: _getErrorMessage(e));
    }
    notifyListeners();
  }

  /// Gửi cảnh báo khẩn cấp
  /// Hỗ trợ 2 trường hợp:
  /// 1. Panic từ trang chủ: Không có location (latitude, longitude = null)
  /// 2. Panic từ chuyến đi: Có location
  Future<void> sendPanic({
    double? latitude,
    double? longitude,
    int? batteryLevel,
  }) async {
    try {
      await tripService.sendPanic(
        latitude: latitude,
        longitude: longitude,
        batteryLevel: batteryLevel,
      );

      // Sau khi gửi panic, refresh trip state
      if (tripService.currentTrip != null) {
        _state = TripActive(
          trip: tripService.currentTrip!,
          timeRemainingMinutes: tripService.currentTrip!.getTimeRemainingMinutes(),
        );
        notifyListeners();
      }
    } catch (e) {
      _state = TripError(message: _getErrorMessage(e));
      notifyListeners();
      rethrow;
    }
  }

  /// Cập nhật vị trí
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    required int batteryLevel,
  }) async {
    try {
      await tripService.updateLocation(
        latitude: latitude,
        longitude: longitude,
        batteryLevel: batteryLevel,
      );
    } catch (e) {
      print('Lỗi khi cập nhật vị trí: $e');
    }
  }

  /// Kết thúc chuyến đi bằng PIN
  Future<void> endTrip({required int tripId, required String pinCode}) async {
    _state = TripLoading();
    notifyListeners();

    try {
      final message = await tripService.endTrip(tripId: tripId, pinCode: pinCode);
      _state = TripEnded(message: message);
    } catch (e) {
      _state = TripError(message: _getErrorMessage(e));
    }
    notifyListeners();
  }

  /// Kết thúc chuyến đi bằng PIN với location và battery level
  /// Backend sẽ tự động xử lý:
  /// - Safety PIN: Kết thúc bình thường
  /// - Duress PIN: Gửi duress alert với location và battery
  Future<void> endTripWithLocation({
    required int tripId,
    required String pinCode,
    double? latitude,
    double? longitude,
    int? batteryLevel,
  }) async {
    _state = TripLoading();
    notifyListeners();

    try {
      final message = await tripService.endTripWithLocation(
        tripId: tripId,
        pinCode: pinCode,
        latitude: latitude,
        longitude: longitude,
        batteryLevel: batteryLevel,
      );
      _state = TripEnded(message: message);
    } catch (e) {
      _state = TripError(message: _getErrorMessage(e));
    }
    notifyListeners();
  }

  /// Hủy chuyến đi
  Future<void> cancelTrip() async {
    _state = TripLoading();
    notifyListeners();

    try {
      await tripService.cancelTrip();
      _state = TripEnded(message: 'Đã hủy chuyến đi thành công');
    } catch (e) {
      _state = TripError(message: _getErrorMessage(e));
    }
    notifyListeners();
  }

  /// Xác thực PIN
  Future<String> verifyPin(String pin) async {
    try {
      return await tripService.verifyPin(pin);
    } catch (e) {
      throw _getErrorMessage(e);
    }
  }

  /// Làm mới trạng thái
  void resetState() {
    if (_state is! TripActive) {
      _state = TripInitial();
      notifyListeners();
    }
  }

  /// Callback khi thời gian cập nhật
  void _handleTimeUpdate(int remainingMinutes) {
    _timeRemaining = remainingMinutes;
    if (currentTrip != null) {
      _state = TripActive(
        trip: currentTrip!,
        timeRemainingMinutes: _timeRemaining,
      );
      notifyListeners();
    }
  }

  /// Callback khi chuyến đi hết hạn
  void _handleTripExpired() {
    _state = TripExpired();
    notifyListeners();
  }

  /// Callback khi trạng thái trip thay đổi
  void _handleTripStateChanged(Trip trip) {
    _timeRemaining = trip.getTimeRemainingMinutes();
    _state = TripActive(
      trip: trip,
      timeRemainingMinutes: _timeRemaining,
    );
    notifyListeners();
  }

  /// Lấy thông báo lỗi
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString();

    if (errorStr.contains('Cannot start if already has active trip')) {
      return 'Bạn đã có chuyến đi đang hoạt động';
    }
    if (errorStr.contains('Wrong PIN')) {
      return 'Mã PIN không đúng';
    }
    if (errorStr.contains('No active trip')) {
      return 'Không có chuyến đi đang hoạt động';
    }
    if (errorStr.contains('connection')) {
      return 'Lỗi kết nối. Vui lòng kiểm tra mạng.';
    }

    return 'Có lỗi xảy ra: $errorStr';
  }

  @override
  void dispose() {
    tripService.dispose();
    super.dispose();
  }
}

