// lib/main.dart
import 'package:flutter/material.dart';
import 'package:safetrek_app/utils/theme.dart'; // Import theme của chúng ta
import 'package:safetrek_app/screens/splash_screen.dart';
import 'package:safetrek_app/utils/app_routes.dart';
// Import tất cả các màn hình bạn sẽ dùng trong routes
import 'package:safetrek_app/screens/onboarding_screen.dart';
import 'package:safetrek_app/screens/login_screen.dart';
import 'package:safetrek_app/screens/register_screen.dart';
import 'package:safetrek_app/screens/forgot_password_screen.dart';
import 'package:safetrek_app/screens/reset_password_screen.dart';
import 'package:safetrek_app/screens/dashboard_screen.dart';
import 'package:safetrek_app/screens/panic_alert_screen.dart';
import 'package:safetrek_app/screens/initial_setup/initial_setup_welcome_screen.dart';
import 'package:safetrek_app/injection_container.dart' as di;
import 'package:provider/provider.dart';
import 'package:safetrek_app/screens/auth_view_model.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo Flutter framework được khởi tạo
  await di.init(); // GỌI HÀM KHỞI TẠO DEPENDENCY INJECTION CỦA CHÚNG TA
  runApp(
    ChangeNotifierProvider(
      create: (_) => di.sl<AuthViewModel>(), // Lấy AuthViewModel từ GetIt
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeTrek', // Tên ứng dụng
      theme: appTheme, // Áp dụng theme của chúng ta
      initialRoute: AppRoutes.splash, // Ứng dụng sẽ bắt đầu từ Splash Screen
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
        AppRoutes.resetPassword: (context) => const ResetPasswordScreen(),
        AppRoutes.dashboard: (context) => const DashboardScreen(),
        AppRoutes.panicAlert: (context) => const PanicAlertScreen(),
        AppRoutes.initialSetup: (context) => const InitialSetupWelcomeScreen(),
      },
      debugShowCheckedModeBanner: false, // Ẩn banner debug
    );
  }
}
