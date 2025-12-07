// lib/features/auth/presentation/auth_view_model.dart
// lib/screens/auth_view_model.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

import 'auth_state.dart';

class AuthViewModel extends ChangeNotifier {


  final AuthService authService;

  AuthViewModel({required this.authService});

  // Getter tiện ích để lấy user hiện tại từ service
  User? get currentUser => authService.currentUser;

  AuthState _state = AuthInitial();
  AuthState get state => _state;

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }




  Future<void> performLogin(String email, String password) async {
    _setState(AuthLoading());
    try {
      // Gọi trực tiếp service
      final user = await authService.login(email, password);
      _setState(AuthSuccess(user));
    } catch (e) {
      // Bắt lỗi (Exception) từ Service và chuyển thành State lỗi
      // Ở đây chúng ta tạm dùng AuthFailure chung cho đơn giản
      _setState(AuthError(_mapExceptionToMessage(e)));
    }
  }

  Future<void> performRegister(String email, String password) async {
    _setState(AuthLoading());
    try {
      final user = await authService.register(email, password);
      _setState(AuthSuccess(user));
    } catch (e) {
      _setState(AuthError(_mapExceptionToMessage(e)));
    }
  }

  Future<void> performForgotPassword(String email) async {
    _setState(AuthLoading());
    try {
      await authService.forgotPassword(email);
      _setState(AuthPasswordResetEmailSent());
    } catch (e) {
      _setState(AuthError(_mapExceptionToMessage(e)));
    }
  }

  Future<void> performResetPassword(String email, String newPassword) async {
    _setState(AuthLoading());
    try {
      await authService.resetPassword(email, newPassword);
      _setState(AuthPasswordResetSuccess());
    } catch (e) {
      _setState(AuthError(_mapExceptionToMessage(e)));
    }
  }

  Future<void> performLogout() async {
    _setState(AuthLoading());
    try {
      await authService.logout();
      _setState(AuthLoggedOut());
    } catch (e) {
      _setState(AuthError(_mapExceptionToMessage(e)));
    }
  }

  Future<void> checkIfLoggedIn() async {
    _setState(AuthLoading());
    try {
      final isLoggedIn = await authService.checkLoginStatus();
      if (isLoggedIn && authService.currentUser != null) {
        _setState(AuthSuccess(authService.currentUser!));
      } else {
        _setState(AuthLoggedOut());
      }
    } catch (e) {
      _setState(AuthError(_mapExceptionToMessage(e)));
    }
  }

  void resetState() {
    _state = AuthInitial();
    notifyListeners();
  }

  // Hàm tiện ích để chuyển Exception thành thông báo lỗi thân thiện
  String _mapExceptionToMessage(Object error) {

    // Ví dụ: if (error is NetworkException) return 'Lỗi mạng...';
    return error.toString().replaceAll('Exception: ', '');
  }
}