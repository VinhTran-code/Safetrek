// lib/models/auth_response.dart

import 'user.dart';

class AuthResponse {
  final bool success;
  final String message;
  final UserModel user;
  final String token;

  AuthResponse({
    required this.success,
    required this.message,
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Debug: In ra JSON để kiểm tra
    print('🔍 Parsing AuthResponse from JSON: $json');

    return AuthResponse(
      success: json['success'] == true,  // Safer null check
      message: json['message'] as String? ?? 'Unknown response',
      user: UserModel.fromJson(json['data']['user'] as Map<String, dynamic>),
      token: json['data']['token'] as String,
    );
  }
}

class RegisterRequest {
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String password;
  final String passwordConfirmation;

  RegisterRequest({
    required this.fullName,
    required this.phoneNumber,
    this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}

class LoginRequest {
  final String phoneNumber;
  final String password;

  LoginRequest({
    required this.phoneNumber,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'password': password,
    };
  }
}

