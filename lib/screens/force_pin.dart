import 'package:flutter/material.dart';
import 'package:safetrek_app/injection_container.dart';
import 'package:safetrek_app/services/pin_service.dart';
import 'package:safetrek_app/screens/pin_setup_mode.dart';

class ForcePinSetupScreen extends StatefulWidget {
  // Thêm các tham số để nhận dữ liệu từ màn hình trước
  final PinSetupMode mode;
  final String? safetyPin; // Dùng cho luồng thiết lập ban đầu

  const ForcePinSetupScreen({
    super.key,
    this.mode = PinSetupMode.initialSetup, // Mặc định là luồng thiết lập
    this.safetyPin, // Có thể null nếu ở chế độ cập nhật
  });

  @override
  State<ForcePinSetupScreen> createState() => _ForcePinSetupScreenState();
}

class _ForcePinSetupScreenState extends State<ForcePinSetupScreen> {
  String _newPin = '';
  final int _pinLength = 4;

  // Thêm các biến trạng thái mới
  bool _isLoading = false;
  String? _errorMessage;

  // Thêm biến để track bước hiện tại (chỉ dùng cho mode update)
  int _currentStep = 1; // 1 = Nhập PIN cũ, 2 = Nhập PIN mới

  // Lấy PinService từ GetIt
  final PinService _pinService = sl<PinService>();

  // Màu sắc
  final Color _backgroundColor = const Color(0xFF0F172A);
  final Color _buttonColor = const Color(0xFF1F2937);
  final Color _textColor = Colors.white;

  void _onNumberPressed(int number) {
    if (_isLoading) return;

    setState(() {
      _errorMessage = null;
      if (_newPin.length < _pinLength) {
        _newPin += number.toString();
      }
    });

    if (_newPin.length == _pinLength) {
      _handlePinEntered(_newPin);
    }
  }

  void _onDeletePressed() {
    if (_isLoading) return;
    setState(() {
      if (_newPin.isNotEmpty) {
        _newPin = _newPin.substring(0, _newPin.length - 1);
      }
    });
  }

  // Hàm xử lý chính, thay thế cho _finishPinSetup
  Future<void> _handlePinEntered(String duressPin) async {
    // Dựa vào chế độ để quyết định hành động
    if (widget.mode == PinSetupMode.update) {
      // Nếu đang ở bước 1 (xác thực PIN cũ)
      if (_currentStep == 1) {
        await _verifyOldPin(duressPin);
      } else {
        // Bước 2: Cập nhật PIN mới
        await _updateDuressPin(duressPin);
      }
    } else {
      // Đảm bảo có safetyPin trong luồng thiết lập ban đầu
      if (widget.safetyPin == null) {
        setState(() {
          _errorMessage = 'Lỗi: Không tìm thấy PIN an toàn.';
          _newPin = '';
        });
        return;
      }
      await _setupBothPins(widget.safetyPin!, duressPin);
    }
  }

  // Hàm xác thực PIN cũ
  Future<void> _verifyOldPin(String pin) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Gọi API verify PIN
      final result = await _pinService.verifyTripPin(pin);

      if (mounted) {
        // Kiểm tra phải là duress PIN
        if (result['pin_type'] == 'duress') {
          setState(() {
            _newPin = '';
            _currentStep = 2; // Chuyển sang bước 2
            _isLoading = false;
          });
        } else {
          // Nếu nhập PIN an toàn
          setState(() {
            _errorMessage = 'Vui lòng nhập PIN ép buộc hiện tại';
            _newPin = '';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'PIN không đúng';
          _newPin = '';
          _isLoading = false;
        });
      }
    }
  }

  // Hàm gọi API để cập nhật chỉ PIN ép buộc
  Future<void> _updateDuressPin(String pin) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _pinService.updateDuressPin(pin);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật PIN ép buộc thành công!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Quay về màn hình Cài đặt
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _newPin = ''; // Xóa PIN để nhập lại
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Hàm gọi API để thiết lập cả hai PIN (luồng ban đầu)
  Future<void> _setupBothPins(String safetyPin, String duressPin) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _pinService.setupPins(safetyPin: safetyPin, duressPin: duressPin);
      if (mounted) {
        // Sau khi thiết lập thành công, quay về 2 lần để thoát khỏi cả 2 màn hình PIN
        int count = 0;
        Navigator.of(context).popUntil((_) => count++ >= 2);
        // TODO: Điều hướng tới màn hình tiếp theo của luồng thiết lập, ví dụ: Quyền truy cập
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _newPin = ''; // Xóa PIN để nhập lại
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              widget.mode == PinSetupMode.update
                ? (_currentStep == 1 ? 'Xác thực PIN cũ' : 'Nhập PIN Ép buộc mới')
                : 'Thiết lập PIN Ép buộc',
              style: TextStyle(
                color: _textColor,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              widget.mode == PinSetupMode.update
                ? (_currentStep == 1
                    ? 'Nhập PIN ép buộc hiện tại để xác thực'
                    : 'Mã PIN mới phải khác với PIN an toàn')
                : 'Mã PIN này dùng khi bạn bị đe doạ',
              style: TextStyle(
                color: _textColor.withOpacity(0.7),
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 60.0),
            Column(
              children: [
                const Icon(Icons.lock, color: Colors.white, size: 32.0),
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
                            height: 16, width: 16,
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
                Row(children: <Widget>[_buildNumberButton(1), _buildNumberButton(2), _buildNumberButton(3)]),
                Row(children: <Widget>[_buildNumberButton(4), _buildNumberButton(5), _buildNumberButton(6)]),
                Row(children: <Widget>[_buildNumberButton(7), _buildNumberButton(8), _buildNumberButton(9)]),
                Row(
                  children: <Widget>[
                    _buildSpecialButton(null, null),
                    _buildNumberButton(0),
                    _buildSpecialButton(
                      Icon(Icons.backspace_outlined, color: _textColor, size: 28.0),
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
    bool isFilled = index < _newPin.length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      width: 24.0,
      height: 24.0,
      decoration: BoxDecoration(
        color: isFilled ? _textColor : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: _errorMessage != null ? Colors.redAccent : _textColor.withOpacity(0.5),
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
              color: _buttonColor,
              borderRadius: BorderRadius.circular(16.0),
            ),
            alignment: Alignment.center,
            child: Text(
              number.toString(),
              style: TextStyle(
                color: _textColor,
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
              color: onPressed != null ? _buttonColor : Colors.transparent,
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
