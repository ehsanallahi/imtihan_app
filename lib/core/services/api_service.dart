import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Production URL — set this after deploying to Vercel
  static const String _productionUrl = 'https://www.imtihan.app/api';

  // Local development fallback
  static const String _devUrl = 'http://10.14.46.247:3000/api';

  /// Returns the active base URL.
  /// Priority: saved override > production > dev fallback
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final override = prefs.getString('api_base_url');
    if (override != null && override.isNotEmpty) return override;
    if (_productionUrl.isNotEmpty) return _productionUrl;
    return _devUrl;
  }

  /// Allows changing the base URL at runtime (e.g. from a dev settings screen).
  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', url);
  }

  /// Clears the override so it falls back to the compiled default.
  static Future<void> resetBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_base_url');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String endpoint) async {
    final base = await getBaseUrl();
    final url = Uri.parse('$base$endpoint');
    final headers = await _getHeaders();
    debugPrint('ApiService GET: $url');
    final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));
    debugPrint('ApiService GET Response [${response.statusCode}]: ${response.body}');
    return response;
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final base = await getBaseUrl();
    final url = Uri.parse('$base$endpoint');
    final headers = await _getHeaders();
    debugPrint('ApiService POST: $url');
    final response = await http.post(url, headers: headers, body: jsonEncode(body)).timeout(const Duration(seconds: 10));
    debugPrint('ApiService POST Response [${response.statusCode}]: ${response.body}');
    return response;
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final base = await getBaseUrl();
    final url = Uri.parse('$base$endpoint');
    final headers = await _getHeaders();
    debugPrint('ApiService PUT: $url');
    return await http.put(url, headers: headers, body: jsonEncode(body)).timeout(const Duration(seconds: 10));
  }

  static Future<http.Response> patch(String endpoint, Map<String, dynamic> body) async {
    final base = await getBaseUrl();
    final url = Uri.parse('$base$endpoint');
    final headers = await _getHeaders();
    debugPrint('ApiService PATCH: $url');
    return await http.patch(url, headers: headers, body: jsonEncode(body)).timeout(const Duration(seconds: 10));
  }

  static Future<http.Response> multipartPost(String endpoint, String filePath) async {
    final base = await getBaseUrl();
    final url = Uri.parse('$base$endpoint');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    var request = http.MultipartRequest('POST', url);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    
    debugPrint('ApiService MULTIPART POST: $url');
    final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
    return await http.Response.fromStream(streamedResponse);
  }
}
