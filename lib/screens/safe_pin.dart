import 'package:flutter/material.dart';
import 'package:safetrek_app/injection_container.dart';
import 'package:safetrek_app/services/pin_service.dart';
import 'package:safetrek_app/screens/pin_setup_mode.dart';
import 'package:safetrek_app/screens/force_pin.dart';

class SafePinSetupScreen extends StatefulWidget {
  // Thêm mode để biết màn hình đang ở chế độ "thiết lập" hay "cập nhật"
  final PinSetupMode mode;

  const SafePinSetupScreen({super.key, this.mode = PinSetupMode.initialSetup});

  @override
  State<SafePinSetupScreen> createState() => _SafePinSetupScreenState();
}

class _SafePinSetupScreenState extends State<SafePinSetupScreen> {
  String _newPin = '';
  final int _pinLength = 4;

  // Thêm các biến trạng thái mới
  bool _isLoading = false;
  String? _errorMessage;

  // Lấy PinService từ GetIt
  final PinService _pinService = sl<PinService>();

  // Màu sắc & Kích thước
  final Color _backgroundColor = const Color(0xFF0F172A);
  final Color _buttonColor = const Color(0xFF1F2937);
  final Color _textColor = Colors.white;

  void _onNumberPressed(int number) {
    if (_isLoading) return;

    setState(() {
      _errorMessage = null; // Xóa lỗi cũ khi người dùng nhập
      if (_newPin.length < _pinLength) {
        _newPin += number.toString();
      }
    });

    if (_newPin.length == _pinLength) {
      // Gọi hàm xử lý tổng quát
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
  Future<void> _handlePinEntered(String pin) async {
    // Dựa vào chế độ được truyền vào để quyết định hành động
    if (widget.mode == PinSetupMode.update) {
      await _updatePin(pin);
    } else {
      _navigateToDuressPinScreen(pin);
    }
  }

  // Hàm gọi API để cập nhật PIN
  Future<void> _updatePin(String pin) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _pinService.updateSafetyPin(pin);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật PIN an toàn thành công!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Quay về màn hình cài đặt
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Hàm điều hướng tới màn hình PIN nguy hiểm (dành cho luồng thiết lập ban đầu)
  void _navigateToDuressPinScreen(String safetyPin) {
    setState(() {
      _newPin = '';
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForcePinSetupScreen(safetyPin: safetyPin, mode: widget.mode),
      ),
    );
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
              widget.mode == PinSetupMode.update ? 'Đổi PIN An toàn' : 'Thiết lập PIN An toàn',
              style: TextStyle(
                color: _textColor,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Mã PIN này dùng để check-in bình thường',
              style: TextStyle(
                color: _textColor.withOpacity(0.7),
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 60.0),
            Column(
              children: [
                const Icon(
                  Icons.lock,
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
