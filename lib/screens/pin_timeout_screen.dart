import 'package:flutter/material.dart';
import 'package:safetrek_app/injection_container.dart';
import 'package:safetrek_app/screens/trip_view_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'dart:async';

/// Màn hình nhập PIN khi hết thời gian chuyến đi
/// Nếu không nhập trong 60 giây (1 phút) -> Backend scheduler sẽ TỰ ĐỘNG gửi timer_expired alert
class PinTimeoutScreen extends StatefulWidget {
  final int? tripId;
  final int timeoutSeconds; // Thời gian chờ trước khi backend tự động gửi timer_expired (mặc định 60s = 1 phút, đồng bộ với scheduler)

  const PinTimeoutScreen({
    super.key,
    this.tripId,
    this.timeoutSeconds = 60, // Đồng bộ với backend scheduler (chạy mỗi 1 phút)
  });

  @override
  State<PinTimeoutScreen> createState() => _PinTimeoutScreenState();
}

class _PinTimeoutScreenState extends State<PinTimeoutScreen> {
  String _pin = '';
  final int _pinLength = 4;

  bool _isLoading = false;
  String? _errorMessage;

  late final TripViewModel _tripViewModel;
  final Battery _battery = Battery();

  Timer? _timeoutTimer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _tripViewModel = sl<TripViewModel>();
    _remainingSeconds = widget.timeoutSeconds;
    _startTimeoutTimer();
  }


  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  /// Lấy battery level
  Future<int> _getBatteryLevel() async {
    try {
      final batteryLevel = await _battery.batteryLevel;
      return batteryLevel;
    } catch (e) {
      print('⚠️ Không lấy được battery level: $e');
      return 100; // Default
    }
  }

  /// Bắt đầu đếm ngược timeout
  void _startTimeoutTimer() {
    _timeoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
        _handleTimeout();
      }
    });
  }

  /// Xử lý khi hết timeout -> Cập nhật location/battery cuối cùng, sau đó backend scheduler sẽ tự động gửi timer_expired alert
  Future<void> _handleTimeout() async {
    if (!mounted) return;

    print('⏰ Timeout - Đang cập nhật location/battery cuối cùng trước khi backend gửi TIMER_EXPIRED alert');

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: Color(0xFF1F2937),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Đang cập nhật vị trí...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    try {
      // Lấy vị trí và battery level cuối cùng
      Position? position;
      int batteryLevel = await _getBatteryLevel();

      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 5));

        print('📍 Final Location: ${position.latitude}, ${position.longitude}');
        print('🔋 Final Battery Level: $batteryLevel%');
      } catch (e) {
        print('⚠️ Không lấy được vị trí cuối: $e');
      }

      // Cập nhật location và battery cuối cùng vào server
      // Backend scheduler sẽ dùng thông tin này để gửi timer_expired alert
      if (position != null && widget.tripId != null) {
        await _tripViewModel.updateLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          batteryLevel: batteryLevel,
        );
        print('✅ Đã cập nhật location/battery cuối cùng');
      }
    } catch (e) {
      print('⚠️ Lỗi khi cập nhật location cuối: $e');
    }

    if (!mounted) return;

    // Tự động về trang chủ mà không hiển thị dialog
    // Lý do: Nếu người dùng đang bị ép buộc, không thể nhấn nút "Đã hiểu"
    // Backend scheduler sẽ tự động gửi timer_expired alert
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _onNumberPressed(int number) {
    if (_isLoading) return;

    setState(() {
      _errorMessage = null;
      if (_pin.length < _pinLength) {
        _pin += number.toString();
      }
    });

    if (_pin.length == _pinLength) {
      _validatePinOnServer(_pin);
    }
  }

  Future<void> _validatePinOnServer(String enteredPin) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.tripId == null) {
        throw Exception('Không tìm thấy thông tin chuyến đi');
      }

      print('🔐 Validating PIN for trip_id: ${widget.tripId}');
      print('🔑 Entered PIN: $enteredPin');

      // Lấy vị trí và battery level trước khi gửi
      Position? position;
      int batteryLevel = await _getBatteryLevel();

      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 5));

        print('📍 Location: ${position.latitude}, ${position.longitude}');
        print('🔋 Battery Level: $batteryLevel%');
      } catch (e) {
        print('⚠️ Không lấy được vị trí: $e');
      }

      // Gọi API endTripWithLocation
      // Backend sẽ TỰ ĐỘNG:
      // - Nếu là Safety PIN -> Kết thúc bình thường
      // - Nếu là Duress PIN -> Gửi duress log ẨM THẦM + giả vờ thành công
      await _tripViewModel.endTripWithLocation(
        tripId: widget.tripId!,
        pinCode: enteredPin,
        latitude: position?.latitude,
        longitude: position?.longitude,
        batteryLevel: batteryLevel,
      );

      // Kiểm tra kết quả
      if (_tripViewModel.state is TripEnded) {
        final message = (_tripViewModel.state as TripEnded).message;
        print('✅ Kết thúc chuyến đi thành công: $message');

        if (mounted) {
          // LUÔN hiển thị thông báo thành công (để lừa kẻ tấn công)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chuyến đi đã kết thúc. Bạn đã an toàn!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      } else if (_tripViewModel.state is TripError) {
        final error = (_tripViewModel.state as TripError).message;
        throw Exception(error);
      }
    } catch (e) {
      print('❌ Xác thực PIN thất bại: $e');

      String errorMsg = 'Mã PIN không đúng. Vui lòng thử lại.';

      if (e.toString().contains('400') || e.toString().contains('Bad Request')) {
        errorMsg = 'Mã PIN không đúng hoặc chuyến đi không hợp lệ.';
      }

      if (mounted) {
        setState(() {
          _errorMessage = errorMsg;
          _pin = '';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onDeletePressed() {
    if (_isLoading) return;

    setState(() {
      _errorMessage = null;
      if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Không cho phép back
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Warning banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
                    const SizedBox(height: 8),
                    const Text(
                      'ĐÃ HẾT THỜI GIAN CHUYẾN ĐI',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vui lòng nhập mã PIN để xác nhận an toàn',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Countdown timer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      _remainingSeconds > 0
                          ? 'Tự động gửi cảnh báo sau: $_remainingSeconds giây'
                          : 'Đang gửi cảnh báo...',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // PIN input
              Column(
                children: [
                  const Icon(
                    Icons.lock_outline,
                    color: Colors.white,
                    size: 32.0,
                  ),
                  const SizedBox(height: 32.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pinLength, (index) => _buildPinCircle(index)),
                  ),
                  SizedBox(
                    height: 24,
                    child: _isLoading
                        ? const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                          )
                        : _errorMessage != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : null,
                  ),
                ],
              ),
              const Spacer(),

              // Number pad
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _buildNumberButton(1),
                      _buildNumberButton(2),
                      _buildNumberButton(3),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      _buildNumberButton(4),
                      _buildNumberButton(5),
                      _buildNumberButton(6),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      _buildNumberButton(7),
                      _buildNumberButton(8),
                      _buildNumberButton(9),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      _buildSpecialButton(null, null),
                      _buildNumberButton(0),
                      _buildSpecialButton(
                        const Icon(Icons.backspace_outlined, color: Colors.white, size: 28.0),
                        _onDeletePressed,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinCircle(int index) {
    bool isFilled = index < _pin.length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      width: 24.0,
      height: 24.0,
      decoration: BoxDecoration(
        color: isFilled ? Colors.white : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: _errorMessage != null ? Colors.redAccent : Colors.white.withOpacity(0.5),
          width: 2.0,
        ),
      ),
    );
  }

  Widget _buildNumberButton(int number) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () => _onNumberPressed(number),
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            height: 60.0,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(16.0),
            ),
            alignment: Alignment.center,
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialButton(Widget? child, VoidCallback? onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            height: 60.0,
            decoration: BoxDecoration(
              color: child != null ? const Color(0xFF1F2937) : Colors.transparent,
              borderRadius: BorderRadius.circular(16.0),
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

