// lib/features/auth/presentation/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:safetrek_app/utils/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:safetrek_app/screens/auth_view_model.dart';
import 'package:safetrek_app/screens/auth_state.dart';
// import 'package:safetrek_app/features/auth/presentation/screens/onboarding_screen.dart'; // Sẽ tạo tiếp theo

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Chuyển việc điều hướng vào trong Consumer để xử lý logic bất đồng bộ
    // Dòng này có thể xóa đi hoặc giữ lại như một fallback
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) { // Kiểm tra widget còn tồn tại
         // Chỉ điều hướng nếu chưa có trạng thái đăng nhập nào được xử lý
        final viewModel = Provider.of<AuthViewModel>(context, listen: false);
        if (viewModel.state is AuthInitial) {
           Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
        }
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthViewModel>( 
        builder: (context, viewModel, child) {
          if (viewModel.state is AuthSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
              viewModel.resetState(); 
            });
          } else if (viewModel.state is AuthLoggedOut) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
              viewModel.resetState(); 
            });
          } else if (viewModel.state is AuthError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lỗi kiểm tra đăng nhập: ${(viewModel.state as AuthError).message}')),
              );
              Navigator.pushReplacementNamed(context, AppRoutes.onboarding); 
              viewModel.resetState();
            });
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // *** TĂNG KÍCH THƯỚC LOGO Ở ĐÂY ***
                Image.asset(
                  'assets/images/app_logo.png',
                  height: 200, // Tăng từ 150 lên 200
                ),
                const SizedBox(height: 48),
                const CircularProgressIndicator(),
              ],
            ),
          );
        },
      ),
    );
  }
}