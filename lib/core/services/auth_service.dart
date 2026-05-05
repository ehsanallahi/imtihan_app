import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthService {
  static Future<bool> login(String email, String password) async {
    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_data', jsonEncode(data['user']));
        
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> register(String name, String email, String password, {String? grade, String? board}) async {
    try {
      final response = await ApiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'grade': grade,
        'board': board,
      });

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  static Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post('/users/me', data);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        // Handle case where user is nested under 'user' key
        final userData = data.containsKey('user') ? data['user'] : data;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(userData));
        return true;
      } else {
        debugPrint('Profile update failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Profile update error: $e');
      return false;
    }
  }
}
