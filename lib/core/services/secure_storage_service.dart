import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Migrates the auth token from SharedPreferences to FlutterSecureStorage
  /// and deletes it from SharedPreferences.
  static Future<void> migrateAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(_tokenKey)) {
        final token = prefs.getString(_tokenKey);
        if (token != null) {
          await saveToken(token);
        }
        await prefs.remove(_tokenKey);
        debugPrint('SecureStorageService: Successfully migrated auth token.');
      }
    } catch (e) {
      debugPrint('SecureStorageService: Error migrating auth token: $e');
    }
  }
}
