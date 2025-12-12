import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() {
    // Implement password change logic here
    String currentPassword = _currentPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmNewPassword = _confirmNewPasswordController.text;

    if (newPassword != confirmNewPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu mới và xác nhận mật khẩu không khớp.')),
      );
      return;
    }

    // Call API to change password
    print('Current Password: $currentPassword');
    print('New Password: $newPassword');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đổi mật khẩu thành công! (Logic chưa được triển khai)')),
    );
    // Navigator.pop(context); // Go back to profile screen after successful change
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center( // Wrapped with Center to align the text
              child: const Text(
                'Đổi Mật Khẩu',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 60), // Increased height for more spacing
            _buildPasswordField(
              controller: _currentPasswordController,
              hintText: 'MẬT KHẨU HIỆN TẠI',
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              controller: _newPasswordController,
              hintText: 'MẬT KHẨU MỚI',
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              controller: _confirmNewPasswordController,
              hintText: 'XÁC NHẬN MẬT KHẨU MỚI',
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('CẬP NHẬT MẬT KHẨU', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
  }) {
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
          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}