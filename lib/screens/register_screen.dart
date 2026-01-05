// lib/features/auth/presentation/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:safetrek_app/utils/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:safetrek_app/screens/auth_state.dart';
import 'package:safetrek_app/screens/auth_view_model.dart';
import 'package:safetrek_app/utils/validation_helper.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register(AuthViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus(); // Đóng bàn phím
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mật khẩu và xác nhận mật khẩu không khớp.')),
        );
        return;
      }
      await viewModel.performRegister(
        fullName: _fullNameController.text,
        phoneNumber: _phoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor), // Màu icon back
      ),
      body: Consumer<AuthViewModel>( // Bọc phần body bằng Consumer
        builder: (context, viewModel, child) {
          // Lắng nghe trạng thái và điều hướng/hiển thị thông báo
          if (viewModel.state is AuthLoading) {
            // Có thể hiển thị một loading indicator toàn màn hình
          } else if (viewModel.state is AuthSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đăng ký thành công! Vui lòng đăng nhập để tiếp tục.'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ),
              );
              // Quay về màn hình đăng nhập thay vì chuyển đến initial setup
              Navigator.pushReplacementNamed(context, AppRoutes.login);
              viewModel.resetState();
            });
          } else if (viewModel.state is AuthError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text((viewModel.state as AuthError).message)),
              );
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
                    Text(
                      'Tạo tài khoản mới',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Input Tên đầy đủ
                    TextFormField(
                      controller: _fullNameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: 'Tên đầy đủ',
                        hintText: 'Nhập tên của bạn',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên đầy đủ';
                        }
                        if (value.length > 255) {
                          return 'Họ tên tối đa 255 ký tự';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Input Số điện thoại
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                        hintText: '0xxxxxxxxx hoặc +84xxxxxxxxx',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (value) {
                        // Sử dụng ValidationHelper
                        return ValidationHelper.validatePhone(value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Input Email (optional)
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email (không bắt buộc)',
                        hintText: 'Nhập email của bạn',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        // Sử dụng ValidationHelper với required = false
                        return ValidationHelper.validateEmail(value, required: false);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Input Mật khẩu
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

                    // Input Xác nhận Mật khẩu
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Xác nhận Mật khẩu',
                        hintText: 'Nhập lại mật khẩu của bạn',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng xác nhận mật khẩu';
                        }
                        // Không cần kiểm tra khớp ở đây, sẽ kiểm tra trong _register
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Nút Đăng ký
                    ElevatedButton(
                      onPressed: (viewModel.state is AuthLoading) ? null : () => _register(viewModel), // Vô hiệu hóa khi đang loading
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: (viewModel.state is AuthLoading)
                          ? const CircularProgressIndicator(color: Colors.white) // Hiển thị loading
                          : const Text(
                        'ĐĂNG KÝ',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
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