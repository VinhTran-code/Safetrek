import 'package:flutter/material.dart';
import 'package:safetrek_app/injection_container.dart';
import 'package:safetrek_app/services/pin_service.dart';

class SubmitPinScreen extends StatefulWidget {
  const SubmitPinScreen({super.key});

  @override
  State<SubmitPinScreen> createState() => _SubmitPinScreenState();
}

class _SubmitPinScreenState extends State<SubmitPinScreen> {
  String _pin = '';
  final int _pinLength = 4;

  bool _isLoading = false;
  String? _errorMessage;

  final PinService _pinService = sl<PinService>();

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
      // Gọi hàm mới, nó sẽ trả về 'safety' hoặc 'duress'
      final pinType = await _pinService.verifyTripPin(enteredPin);

      if (pinType == 'safety') {
        print('Xác thực PIN an toàn thành công!');
        if (mounted) {
          // Pop về trang chủ
          Navigator.pop(context, true);
          Navigator.pop(context, true);
          Navigator.pop(context, true);
        }
      } else if (pinType == 'duress') {
        print('PIN ép buộc đã được nhập!');
        // Server sẽ lo việc gửi cảnh báo. App chỉ cần đóng màn hình PIN.
        if (mounted) {
          //Sửa phần này để PIN ép buộc hoạt dđộng
        }
      }
    } catch (e) {
      print('Xác thực PIN thất bại: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Mã PIN không đúng. Vui lòng thử lại.';
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
