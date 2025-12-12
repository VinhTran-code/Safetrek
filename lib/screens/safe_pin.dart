import 'package:flutter/material.dart';

class SafePinSetupScreen extends StatefulWidget {
  const SafePinSetupScreen({super.key});

  @override
  State<SafePinSetupScreen> createState() => _SafePinSetupScreenState();
}

class _SafePinSetupScreenState extends State<SafePinSetupScreen> {
  // Biến lưu trữ mã PIN mới đang được nhập
  String _newPin = '';
  // Độ dài PIN dự kiến (4 chữ số)
  final int _pinLength = 4;

  // Màu sắc & Kích thước (Đồng bộ với SubmitPinScreen)
  final Color _backgroundColor = const Color(0xFF0F172A); // Blue/Slate 900
  final Color _buttonColor = const Color(0xFF1F2937); // Nền nút
  final Color _textColor = Colors.white;

  // Hàm xử lý khi nhấn một nút số
  void _onNumberPressed(int number) {
    setState(() {
      if (_newPin.length < _pinLength) {
        _newPin += number.toString();
      }
    });
    // Xử lí khi nhập xong PIN mới
    if (_newPin.length == _pinLength) {
      _finishPinSetup(_newPin);
      Navigator.pop(context);
    }
  }

  // Hàm xử lý khi nhấn nút xóa (backspace)
  void _onDeletePressed() {
    setState(() {
      if (_newPin.isNotEmpty) {
        _newPin = _newPin.substring(0, _newPin.length - 1);
      }
    });
  }

  // Logic hoàn thành thiết lập PIN (Chỉ là placeholder)
  void _finishPinSetup(String pin) {
    // THỰC TẾ: Bạn sẽ lưu trữ PIN này vào Shared Preferences/Secure Storage
    // hoặc chuyển sang màn hình "Xác nhận lại PIN" (Confirm Pin)

    debugPrint('Mã PIN mới đã được thiết lập: $pin');

    // Ví dụ: Thông báo và quay lại
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thiết lập PIN mới: $pin')),
    );
    // Navigator.pop(context); // Quay lại màn hình trước đó
  }

  // Widget hiển thị một ô PIN (chưa nhập hoặc đã nhập)
  Widget _buildPinCircle(int index) {
    bool isFilled = index < _newPin.length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      width: 24.0, // Kích thước đồng bộ
      height: 24.0, // Kích thước đồng bộ
      decoration: BoxDecoration(
        color: isFilled ? _textColor : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: _textColor.withOpacity(0.5),
          width: 2.0,
        ),
      ),
    );
  }

  // Widget hiển thị một nút số lớn (Đồng bộ với SubmitPinScreen)
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

  // Widget hiển thị nút xóa (Backspace) hoặc nút số 0 hoặc ô trống (Đồng bộ với SubmitPinScreen)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        // Nút quay lại (Giữ lại theo ảnh gốc)
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
            // Phần tiêu đề (Đồng bộ kích thước)
            Text(
              'Thiết lập PIN An toàn',
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

            // Phần hiển thị PIN đang nhập (Đồng bộ kích thước)
            Column(
              children: [
                Icon(
                  Icons.lock, // Icon khóa theo ảnh gốc
                  color: _textColor,
                  size: 32.0, // Kích thước đồng bộ
                ),
                const SizedBox(height: 32.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pinLength, (index) => _buildPinCircle(index)),
                ),
              ],
            ),

            const Spacer(), // Đẩy bàn phím số xuống dưới

            // Bàn phím số (Sử dụng lại cấu trúc từ SubmitPinScreen)
            Column(
              children: <Widget>[
                // Hàng 1: 1, 2, 3
                Row(
                  children: <Widget>[
                    _buildNumberButton(1),
                    _buildNumberButton(2),
                    _buildNumberButton(3),
                  ],
                ),
                // Hàng 2: 4, 5, 6
                Row(
                  children: <Widget>[
                    _buildNumberButton(4),
                    _buildNumberButton(5),
                    _buildNumberButton(6),
                  ],
                ),
                // Hàng 3: 7, 8, 9
                Row(
                  children: <Widget>[
                    _buildNumberButton(7),
                    _buildNumberButton(8),
                    _buildNumberButton(9),
                  ],
                ),
                // Hàng 4: Trống, 0, Xóa
                Row(
                  children: <Widget>[
                    _buildSpecialButton(
                      null, // Nút trống
                      null,
                    ),
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
}