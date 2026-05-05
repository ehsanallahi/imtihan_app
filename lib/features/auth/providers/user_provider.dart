import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/content_service.dart';
import '../../mcq/models/subject_model.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  UserStats? _stats;
  Chapter? _recentChapter;
  bool _isLoading = false;

  User? get user => _user;
  UserStats? get stats => _stats;
  Chapter? get recentChapter => _recentChapter;
  bool get isLoading => _isLoading;

  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/users/me');
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        _user = User.fromJson(userData);
      } else {
        // Fallback to local storage if API fails
        final userData = await AuthService.getUser();
        if (userData != null) {
          _user = User.fromJson(userData);
        }
      }

      await fetchStats();
      await fetchRecentChapter();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStats() async {
    try {
      _stats = await ContentService.fetchUserStats();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching stats: $e');
    }
  }

  Future<void> fetchRecentChapter() async {
    try {
      _recentChapter = await ContentService.fetchRecentChapter();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching recent chapter: $e');
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _stats = null;
    _recentChapter = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await AuthService.login(email, password);
      if (success) {
        await loadUserData();
        return true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Data should include name, email, password, grade, board
      final success = await AuthService.register(
        data['name'], 
        data['email'], 
        data['password'],
        grade: data['grade'],
        board: data['board'],
      );
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> updateUser(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      debugPrint('UserProvider: Updating profile with $data');
      final success = await AuthService.updateProfile(data);
      debugPrint('UserProvider: Update success = $success');
      if (success) {
        await loadUserData(); // Refresh local state
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('UserProvider: Update error = $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
