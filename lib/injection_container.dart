import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safetrek_app/core/constants/api_constants.dart';
import 'package:safetrek_app/core/network/api_client.dart';
import 'package:safetrek_app/core/navigation/global_navigator.dart';
import 'package:safetrek_app/services/auth_service.dart';
import 'package:safetrek_app/services/pin_service.dart';
import 'package:safetrek_app/services/trip_service.dart';
import 'package:safetrek_app/screens/auth_view_model.dart';
import 'package:safetrek_app/repositories/guardian_repository.dart';
import 'package:safetrek_app/repositories/trip_repository.dart';
import 'package:safetrek_app/screens/guardian_view_model.dart';
import 'package:safetrek_app/screens/trip_view_model.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External - Phải init trước
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  //! Core
  // Dio client
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

  // API Client
  sl.registerLazySingleton<ApiClient>(
    () {
      final apiClient = ApiClient(dio: sl(), prefs: sl());

      // Setup callback để handle session expired (401)
      apiClient.onUnauthorized = () {
        print('🔄 ApiClient: Session expired detected, redirecting to login...');
        GlobalNavigator.handleSessionExpired();
      };

      return apiClient;
    },
  );

  //! Features - Auth
  // Services
  sl.registerLazySingleton<AuthService>(
    () => AuthService(apiClient: sl(), prefs: sl()),
  );

  sl.registerLazySingleton<PinService>(
    () => PinService(apiClient: sl(), prefs: sl()),
  );

  // ViewModels
  sl.registerFactory(() => AuthViewModel(authService: sl()));

  //! Features - Guardian
  // Repository
  sl.registerLazySingleton<GuardianRepository>(() => GuardianRepository(apiClient: sl()));

  // ViewModel
  sl.registerFactory(
    () => GuardianViewModel(
      repository: sl(),
      authService: sl(),
    ),
  );

  //! Features - Trip
  // Repository
  sl.registerLazySingleton<TripRepository>(() => TripRepository(apiClient: sl()));

  // Service
  sl.registerLazySingleton<TripService>(() => TripService(repository: sl()));

  // ViewModel
  sl.registerFactory(() => TripViewModel(tripService: sl()));
}
