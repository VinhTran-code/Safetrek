import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// Import file constants của bạn (thay đổi đường dẫn cho đúng với dự án của bạn)
import '../../core/constants/api_constants.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    String currentPassword = _currentPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmNewPassword = _confirmNewPasswordController.text.trim();

    // 1. Validation cơ bản
    if (currentPassword.isEmpty || newPassword.isEmpty || confirmNewPassword.isEmpty) {
      _showSnackBar('Vui lòng nhập đầy đủ thông tin.');
      return;
    }

    if (newPassword.length < 6) {
      _showSnackBar('Mật khẩu mới phải từ 6 ký tự trở lên.');
      return;
    }

    if (newPassword != confirmNewPassword) {
      _showSnackBar('Mật khẩu mới và xác nhận mật khẩu không khớp.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Lấy Token bằng key đã định nghĩa trong constants
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString(ApiConstants.tokenKey);

      if (token == null) {
        _showSnackBar('Phiên đăng nhập hết hạn.');
        setState(() => _isLoading = false);
        return;
      }

      // 3. Gọi API sử dụng các hằng số từ api_constants.dart
      final url = Uri.parse('${ApiConstants.baseUrl}/change-password');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Accept': ApiConstants.accept,
          'Authorization': 'Bearer $token', // Gửi token để qua middleware auth:sanctum
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmNewPassword, // Bắt buộc cho rule 'confirmed'
        }),
      );

      final responseData = jsonDecode(response.body);

      // 4. Xử lý phản hồi từ Laravel AuthController
      if (response.statusCode == 200 && responseData['success'] == true) {
        _showSnackBar('Đổi mật khẩu thành công!');
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        // Trả về lỗi từ server (Ví dụ: sai mật khẩu hiện tại)
        _showSnackBar(responseData['message'] ?? 'Đã có lỗi xảy ra.');
      }
    } catch (e) {
      _showSnackBar('Lỗi kết nối Server.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            const Center(
              child: Text(
                'Đổi Mật Khẩu',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
            const SizedBox(height: 60),
            _buildPasswordField(controller: _currentPasswordController, hintText: 'MẬT KHẨU HIỆN TẠI'),
            const SizedBox(height: 20),
            _buildPasswordField(controller: _newPasswordController, hintText: 'MẬT KHẨU MỚI'),
            const SizedBox(height: 20),
            _buildPasswordField(controller: _confirmNewPasswordController, hintText: 'XÁC NHẬN MẬT KHẨU MỚI'),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('CẬP NHẬT MẬT KHẨU', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({required TextEditingController controller, required String hintText}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          icon: const Icon(Icons.lock_outline, color: Colors.grey),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}