import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safetrek_app/utils/api_constants.dart';
import 'package:safetrek_app/services/auth_service.dart';
import 'package:safetrek_app/screens/auth_view_model.dart';
final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // ViewModels
  // Đăng ký AuthViewModel mới, nó chỉ cần authService
  sl.registerFactory(() => AuthViewModel(authService: sl()));

  // Services
  // Đăng ký AuthService mới, nó cần Dio
  sl.registerLazySingleton<AuthService>(() => AuthService(dio: sl()));


  //! Core
  // Dio client cho gọi API
  sl.registerLazySingleton<Dio>(() => Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl, // Đảm bảo ApiConstants đã được chuyển vào utils
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  ));

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}