import 'package:flutter/material.dart';
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
      final userData = await AuthService.getUser();
      if (userData != null) {
        _user = User.fromJson(userData);
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
}
