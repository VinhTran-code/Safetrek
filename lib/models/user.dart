import 'package:equatable/equatable.dart';

// Đây là Entity (model) của người dùng, độc lập với tầng dữ liệu hoặc UI
class User extends Equatable {
  final int id;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String role;
  final bool isPinSetup;
  final String? fcmToken;
  final String? createdAt;

  const User({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    required this.role,
    required this.isPinSetup,
    this.fcmToken,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, fullName, phoneNumber, email, role, isPinSetup, fcmToken, createdAt];
}

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.phoneNumber,
    super.email,
    required super.role,
    required super.isPinSetup,
    super.fcmToken,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Debug: In ra JSON để kiểm tra
    print('🔍 Parsing UserModel from JSON: $json');

    return UserModel(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String?,
      role: json['role'] as String? ?? 'user',
      isPinSetup: json['is_pin_setup'] == true,  // Safer null check
      fcmToken: json['fcm_token'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'role': role,
      'is_pin_setup': isPinSetup,
      'fcm_token': fcmToken,
      'created_at': createdAt,
    };
  }
}