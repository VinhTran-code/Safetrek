// lib/utils/debug_helper.dart

import 'package:shared_preferences/shared_preferences.dart';

/// Helper class để debug token và auth issues
class DebugHelper {
  /// In ra token hiện tại
  static Future<void> printCurrentToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      print('❌ DEBUG: No token found!');
      print('🔍 Available keys: ${prefs.getKeys()}');
    } else {
      print('✅ DEBUG: Token exists: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      print('📏 Token length: ${token.length}');
    }
  }

  /// In ra tất cả keys trong SharedPreferences
  static Future<void> printAllKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    print('🔑 All SharedPreferences keys: $keys');

    for (var key in keys) {
      final value = prefs.get(key);
      if (value is String && value.length > 100) {
        print('  - $key: ${value.substring(0, 50)}... (length: ${value.length})');
      } else {
        print('  - $key: $value');
      }
    }
  }

  /// Kiểm tra token có hợp lệ không
  static Future<bool> validateToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      print('❌ Validate: Token is null or empty');
      return false;
    }

    // Check format: should start with number|
    if (!token.contains('|')) {
      print('⚠️ Validate: Token format seems wrong (missing |)');
      return false;
    }

    print('✅ Validate: Token format looks good');
    return true;
  }

  /// Test API call với token hiện tại
  static Future<void> testTokenWithAPI() async {
    print('🧪 Testing token with API...');
    await printCurrentToken();
    final isValid = await validateToken();

    if (!isValid) {
      print('❌ Token validation failed. User may need to login again.');
    } else {
      print('✅ Token looks valid. If API still returns 401, check backend.');
    }
  }
}

