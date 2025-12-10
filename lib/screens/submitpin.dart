import 'package:flutter/material.dart';
import 'package:safetrek_app/screens/dashboard_screen.dart';

class SubmitPinScreen extends StatefulWidget {
  const SubmitPinScreen({super.key});

  @override
  State<SubmitPinScreen> createState() => _SubmitPinScreenState();
}

class _SubmitPinScreenState extends State<SubmitPinScreen> {
  // Biến lưu trữ mã PIN đã nhập
  String _pin = '';
  // Độ dài PIN dự kiến (4 chữ số)
  final int _pinLength = 4;
  final String _correctPin = '1234'; // Mã PIN đúng

  // Hàm xử lý khi nhấn một nút số
  void _onNumberPressed(int number) {
    setState(() {
      if (_pin.length < _pinLength) {
        _pin += number.toString();
      }
    });
    // Thêm logic xử lý khi PIN đã đủ độ dài ở đây (ví dụ: xác thực)
    if (_pin.length == _pinLength) {
      _validatePin(_pin);
    }
  }

  void _validatePin(String enteredPin) {
    if (enteredPin == _correctPin) {
      print('Xác thực PIN thành công!');
      // Sử dụng pushReplacement để thay thế màn hình PIN bằng màn hình Home,
      // người dùng sẽ không thể quay lại màn hình PIN bằng nút Back.
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      // Navigator.of(context).pushAndRemoveUntil(
      //   MaterialPageRoute(
      //     // Điều hướng về trang chủ
      //     builder: (context) => const DashboardScreen(),
      //   ),
      //       (Route<dynamic> route) => route.isFirst,
      // );
      // Navigator.of(context).popUntil(
      //     (route) {
      //       // Kiểm tra Widget được xây dựng bởi route có phải là DashboardScreen không.
      //       return route.settings is MaterialPageRoute &&
      //           (route.settings as MaterialPageRoute).builder.runtimeType ==
      //                   (BuildContext context) => const DashboardScreen().runtimeType;
      //     }
      // );
    } else {
      print('Xác thực PIN thất bại!');
      setState(() {
        _pin = ''; // Xóa PIN để người dùng nhập lại
        // Thêm logic hiển thị lỗi (ví dụ: Toast, SnackBar) tại đây nếu cần
      });
    }
  }

  // Hàm xử lý khi nhấn nút xóa (backspace)
  void _onDeletePressed() {
    setState(() {
      if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  // Widget hiển thị một ô PIN (chưa nhập hoặc đã nhập)
  Widget _buildPinCircle(int index) {
    bool isFilled = index < _pin.length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      width: 24.0,
      height: 24.0,
      decoration: BoxDecoration(
        color: isFilled ? Colors.white : Colors.transparent, // Màu nền trắng nếu đã nhập, trong suốt nếu chưa
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.5), // Viền mờ cho ô chưa nhập
          width: 2.0,
        ),
      ),
    );
  }

  // Widget hiển thị một nút số lớn
  Widget _buildNumberButton(int number) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () => _onNumberPressed(number),
          borderRadius: BorderRadius.circular(16.0), // Bo góc cho hiệu ứng nhấn
          child: Container(
            height: 60.0,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937), // Màu nền nút đậm hơn nền chính
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

  // Widget hiển thị nút xóa (Backspace) hoặc nút số 0 hoặc ô trống
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
              color: onPressed != null ? const Color(0xFF1F2937) : Colors.transparent, // Màu nền nếu là nút 0 hoặc Xóa
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
      backgroundColor: const Color(0xFF0F172A), // Màu nền tổng thể (Blue/Slate 900)
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A), // Màu nền AppBar
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Phần tiêu đề
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

            // Phần hiển thị PIN đã nhập
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
              ],
            ),

            const Spacer(), // Đẩy bàn phím số xuống dưới

            // Bàn phím số
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
                      const Icon(Icons.backspace_outlined, color: Colors.white, size: 28.0),
                      _onDeletePressed,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20.0), // Khoảng cách cuối cùng
          ],
        ),
      ),
    );
  }
}