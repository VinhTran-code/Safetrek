// lib/core/navigation/global_navigator.dart

import 'package:flutter/material.dart';
import 'package:safetrek_app/widgets/session_expired_dialog.dart';

/// Global Navigator Key để có thể navigate từ bất kỳ đâu
/// Dùng cho các trường hợp:
/// - Session timeout (401) từ API interceptor
/// - Background notifications
/// - Deep links
class GlobalNavigator {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Navigate to a named route
  static Future<T?>? navigateTo<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate and remove all previous routes
  static Future<T?>? navigateAndRemoveUntil<T>(
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return navigatorKey.currentState?.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Pop current route
  static void pop<T>([T? result]) {
    return navigatorKey.currentState?.pop<T>(result);
  }

  /// Show dialog
  static Future<T?> showDialogGlobal<T>({
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      print('⚠️ GlobalNavigator: No context available for dialog');
      throw Exception('No context available');
    }

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }

  /// Show snackbar
  static void showSnackBar(String message, {bool isError = false}) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      print('⚠️ GlobalNavigator: No context available for snackbar');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Handle session expired (401)
  static void handleSessionExpired() {
    print('🔄 GlobalNavigator: Handling session expired...');

    final context = navigatorKey.currentContext;
    if (context == null) {
      print('⚠️ GlobalNavigator: No context available, direct navigate to login');
      navigateAndRemoveUntil('/login');
      return;
    }

    // Show nice dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SessionExpiredDialog(),
    );
  }
}

