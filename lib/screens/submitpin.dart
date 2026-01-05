import 'package:flutter/material.dart';
import 'package:safetrek_app/injection_container.dart';
import 'package:safetrek_app/screens/trip_view_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:safetrek_app/utils/debug_helper.dart';

class SubmitPinScreen extends StatefulWidget {
  final int? tripId;

  const SubmitPinScreen({super.key, this.tripId});

  @override
  State<SubmitPinScreen> createState() => _SubmitPinScreenState();
}

class _SubmitPinScreenState extends State<SubmitPinScreen> {
  String _pin = '';
  final int _pinLength = 4;

  bool _isLoading = false;
  String? _errorMessage;

  late final TripViewModel _tripViewModel;
  final Battery _battery = Battery();

  @override
  void initState() {
    super.initState();
    _tripViewModel = sl<TripViewModel>();
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
      // DEBUG: Check token before API call
      print('🔍 ===== DEBUG: Checking token before endTrip =====');
      await DebugHelper.testTokenWithAPI();
      print('🔍 ================================================');

      // Kiểm tra xem có trip_id hay không
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

      // Gọi API endTrip với PIN, location và battery
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

          // Đợi 1 giây rồi pop về trang chủ
          await Future.delayed(const Duration(seconds: 1));

          if (mounted) {
            // Pop về trang chủ (loại bỏ tất cả màn hình trip)
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      } else if (_tripViewModel.state is TripError) {
        // Hiển thị lỗi
        final error = (_tripViewModel.state as TripError).message;
        throw Exception(error);
      }
    } catch (e) {
      print('❌ Xác thực PIN thất bại: $e');

      // Parse error message from DioException
      String errorMsg = 'Mã PIN không đúng. Vui lòng thử lại.';
      bool needsLogout = false;

      if (e.toString().contains('400') || e.toString().contains('Bad Request')) {
        errorMsg = 'Mã PIN không đúng hoặc chuyến đi không hợp lệ.';
      } else if (e.toString().contains('422')) {
        errorMsg = 'Dữ liệu không hợp lệ. Vui lòng thử lại.';
      } else if (e.toString().contains('401') || e.toString().contains('Unauthenticated')) {
        errorMsg = 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
        needsLogout = true;
      } else if (e.toString().contains('500')) {
        errorMsg = 'Lỗi máy chủ. Vui lòng thử lại sau.';
      }

      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );

        // If 401 error, logout and redirect to login
        if (needsLogout) {
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          }
        } else {
          setState(() {
            _errorMessage = errorMsg;
            _pin = '';
          });
        }
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
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Nhập mã PIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Nhập mã PIN để xác nhận an toàn',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 60.0),
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
              color: onPressed != null ? const Color(0xFF1F2937) : Colors.transparent,
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
