import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Replace with your actual server IP if testing on a real device
  static const String baseUrl = 'http://192.168.1.107:3000/api'; 

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    print('ApiService GET: $url');
    return await http.get(url, headers: headers).timeout(const Duration(seconds: 10));
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    print('ApiService POST: $url');
    return await http.post(url, headers: headers, body: jsonEncode(body)).timeout(const Duration(seconds: 10));
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    print('ApiService PUT: $url');
    return await http.put(url, headers: headers, body: jsonEncode(body)).timeout(const Duration(seconds: 10));
  }

  static Future<http.Response> patch(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    print('ApiService PATCH: $url');
    return await http.patch(url, headers: headers, body: jsonEncode(body)).timeout(const Duration(seconds: 10));
  }
}
