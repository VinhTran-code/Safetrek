// lib/services/trip_service.dart
import 'dart:async';
import 'package:safetrek_app/repositories/trip_repository.dart';
import 'package:safetrek_app/models/trip.dart';

/// Service quản lý logic nghiệp vụ cho Trip
class TripService {
  final TripRepository repository;

  TripService({required this.repository});

  Trip? _currentTrip;
  Trip? get currentTrip => _currentTrip;

  Timer? _locationUpdateTimer;
  Timer? _tripCountdownTimer;

  // Callbacks
  Function(int remainingMinutes)? onTimeUpdate;
  Function()? onTripExpired;
  Function(Trip trip)? onTripStateChanged;

  /// Khởi tạo - Kiểm tra xem có chuyến đi đang hoạt động không
  Future<void> init() async {
    try {
      _currentTrip = await repository.getActiveTrip();
      if (_currentTrip != null && _currentTrip!.isActive) {
        _startTimers();
      }
    } catch (e) {
      print('Lỗi khi khởi tạo TripService: $e');
    }
  }

  /// Bắt đầu chuyến đi mới
  Future<Trip> startTrip({
    required String destinationName,
    required int durationMinutes,
  }) async {
    final request = StartTripRequest(
      destinationName: destinationName,
      durationMinutes: durationMinutes,
    );

    _currentTrip = await repository.startTrip(request);
    _startTimers();
    onTripStateChanged?.call(_currentTrip!);

    return _currentTrip!;
  }

  /// Gửi cảnh báo khẩn cấp
  Future<void> sendPanic({
    required double latitude,
    required double longitude,
    required int batteryLevel,
  }) async {
    final request = PanicRequest(
      latitude: latitude,
      longitude: longitude,
      batteryLevel: batteryLevel,
    );

    await repository.sendPanic(request);

    // Refresh trip state
    await refreshCurrentTrip();
  }

  /// Cập nhật vị trí
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    required int batteryLevel,
  }) async {
    if (_currentTrip == null) return;

    final request = UpdateLocationRequest(
      tripId: _currentTrip!.id,
      latitude: latitude,
      longitude: longitude,
      batteryLevel: batteryLevel,
    );

    await repository.updateLocation(request);
  }

  /// Kết thúc chuyến đi bằng PIN
  Future<String> endTrip({
    required String pinCode,
  }) async {
    if (_currentTrip == null) {
      throw Exception('Không có chuyến đi đang hoạt động');
    }

    final request = EndTripRequest(
      tripId: _currentTrip!.id,
      pinCode: pinCode,
    );

    final result = await repository.endTrip(request);

    _stopTimers();
    _currentTrip = null;
    onTripStateChanged?.call(_currentTrip!);

    return result['message'] as String;
  }

  /// Hủy chuyến đi
  Future<void> cancelTrip() async {
    if (_currentTrip == null) return;

    await repository.cancelTrip(_currentTrip!.id);

    _stopTimers();
    _currentTrip = null;
    onTripStateChanged?.call(_currentTrip!);
  }

  /// Làm mới thông tin chuyến đi hiện tại
  Future<void> refreshCurrentTrip() async {
    _currentTrip = await repository.getActiveTrip();
    if (_currentTrip != null) {
      onTripStateChanged?.call(_currentTrip!);
    }
  }

  /// Lấy lịch sử chuyến đi
  Future<List<Trip>> getTripHistory({int page = 1}) async {
    return await repository.getTripHistory(page: page);
  }

  /// Xác thực PIN
  Future<String> verifyPin(String pin) async {
    return await repository.verifyTripPin(pin);
  }

  /// Bắt đầu các timer
  void _startTimers() {
    // Timer cập nhật thời gian còn lại mỗi phút
    _tripCountdownTimer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) {
        if (_currentTrip != null) {
          final remaining = _currentTrip!.getTimeRemainingMinutes();
          onTimeUpdate?.call(remaining);

          // Nếu hết thời gian
          if (remaining <= 0) {
            _stopTimers();
            onTripExpired?.call();
          }
        }
      },
    );

    // Timer cập nhật vị trí mỗi 60 giây (nếu có GPS)
    // NOTE: Trong production, nên dùng background location service
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 60),
      (timer) async {
        // TODO: Tích hợp với GPS service để lấy vị trí thật
        // Hiện tại chỉ là placeholder
        print('⏰ Location update timer triggered');
      },
    );
  }

  /// Dừng các timer
  void _stopTimers() {
    _tripCountdownTimer?.cancel();
    _locationUpdateTimer?.cancel();
    _tripCountdownTimer = null;
    _locationUpdateTimer = null;
  }

  /// Dispose service
  void dispose() {
    _stopTimers();
    _currentTrip = null;
  }
}

