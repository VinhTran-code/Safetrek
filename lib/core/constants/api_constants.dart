// lib/core/constants/api_constants.dart

import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Base URLs cho các platform khác nhau
  // NOTE:
  // - Web: use localhost (runs in browser on same machine)
  // - Android Emulator: use 10.0.2.2 instead of localhost
  // - Real Device: use your computer's LAN IP (e.g., 192.168.1.x)
  // - iOS Simulator: use localhost

  static const String _baseUrlWeb = 'http://localhost:8000/api';  // For Web
  static const String _baseUrlAndroid = 'http://10.0.2.2:8000/api';  // For Android Emulator
  // static const String _baseUrlRealDevice = 'http://192.168.1.x:8000/api';  // For Real Device (uncomment and replace x with your IP)
  static const String baseUrlProd = 'https://api.safetrek.com';

  // Tự động chọn base URL dựa vào platform
  static String get baseUrl {
    if (kIsWeb) {
      // Nếu chạy trên web browser
      return _baseUrlWeb;
    } else {
      // Nếu chạy trên mobile (Android/iOS)
      return _baseUrlAndroid;

      // Nếu muốn dùng thiết bị thật, uncomment dòng dưới:
      // return _baseUrlRealDevice;
    }
  }

  // Authentication Endpoints
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String me = '/me';
  static const String setupPins = '/setup-pins';
  static const String updateSafetyPin = '/update-safety-pin';
  static const String updateDuressPin = '/update-duress-pin';
  static const String updateFcmToken = '/update-fcm-token';

  // Trip Endpoints
  static const String startTrip = '/trips/start';
  static const String panic = '/trips/panic';
  static const String updateLocation = '/trips/update-location';
  static const String endTrip = '/trips/end';
  static const String getActiveTrip = '/trips/active';

  // Guardian Endpoints
  static const String guardians = '/guardians';
  static const String inviteGuardian = '/guardians/invite';
  static const String respondInvitation = '/guardians/respond';

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}

