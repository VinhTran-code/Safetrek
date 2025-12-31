import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safetrek_app/core/constants/api_constants.dart';
import 'package:safetrek_app/core/network/api_client.dart';
import 'package:safetrek_app/services/auth_service.dart';
import 'package:safetrek_app/services/pin_service.dart';
import 'package:safetrek_app/screens/auth_view_model.dart';
import 'package:safetrek_app/repositories/guardian_repository.dart';
import 'package:safetrek_app/screens/guardian_view_model.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  //! Core
  sl.registerLazySingleton<Dio>(() => Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Accept': ApiConstants.accept,
      },
    ),
  ));

  sl.registerLazySingleton<ApiClient>(() => ApiClient(dio: sl(), prefs: sl()));
  
  //! Features
  // Services - nên là Singleton để giữ trạng thái
  sl.registerLazySingleton<AuthService>(() => AuthService(apiClient: sl(), prefs: sl()));
  sl.registerLazySingleton<PinService>(() => PinService(apiClient: sl(), prefs: sl())); 
  
  // Repositories
  sl.registerLazySingleton<GuardianRepository>(() => GuardianRepository(apiClient: sl()));

  // ViewModels - nên là Factory để mỗi màn hình có state riêng
  sl.registerFactory(() => AuthViewModel(authService: sl()));
  sl.registerFactory(
    () => GuardianViewModel(
      repository: sl(),
      authService: sl(),
    ),
  );
}
