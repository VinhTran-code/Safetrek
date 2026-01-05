// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:safetrek_app/utils/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:safetrek_app/screens/auth_state.dart';
import 'package:safetrek_app/screens/auth_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // 1. Thêm biến để lưu lỗi từ server
  String? _serverError;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login(AuthViewModel viewModel) async {
    // Xóa lỗi cũ khi người dùng thử đăng nhập lại
    setState(() {
      _serverError = null;
    });

    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus(); // Đóng bàn phím
      await viewModel.performLogin(
        _phoneController.text,
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.state is AuthSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final user = (viewModel.state as AuthSuccess).user;
              if (!user.isPinSetup) {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.initialSetup, (route) => false);
              } else {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (route) => false);
              }
              viewModel.resetState();
            });
          } else if (viewModel.state is AuthError) {
            // 2. Thay vì hiển thị SnackBar, cập nhật biến lỗi
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                // Lấy thông báo lỗi từ server và gán vào biến
                _serverError = (viewModel.state as AuthError).message;
              });
              viewModel.resetState();
            });
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/app_logo.png',
                      height: 180,
                    ),
                    const SizedBox(height: 48),

                    Text(
                      'Chào mừng trở lại!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      // 3. Sử dụng biến lỗi để hiển thị dưới ô nhập liệu
                      decoration: InputDecoration(
                        labelText: 'Số điện thoại',
                        hintText: '+84123456789',
                        prefixIcon: const Icon(Icons.phone),
                        errorText: _serverError,
                      ),
                      validator: (value) {
                        // Nếu có lỗi từ server thì không cần validate ở đây nữa
                        if (_serverError != null) return null;

                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số điện thoại';
                        }
                        if (value.length < 10) {
                          return 'Số điện thoại không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Mật khẩu',
                        hintText: 'Nhập mật khẩu của bạn',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        if (value.length < 6) {
                          return 'Mật khẩu phải có ít nhất 6 ký tự';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.forgotPassword);
                        },
                        child: const Text('Quên mật khẩu?'),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: (viewModel.state is AuthLoading) ? null : () => _login(viewModel),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: (viewModel.state is AuthLoading)
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'ĐĂNG NHẬP',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Chưa có tài khoản?'),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.register);
                          },
                          child: const Text('Đăng ký ngay'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
