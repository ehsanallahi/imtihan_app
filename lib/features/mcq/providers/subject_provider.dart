import 'package:flutter/material.dart';
import '../models/subject_model.dart';
import '../../../core/services/content_service.dart';

class SubjectProvider with ChangeNotifier {
  List<Subject> _subjects = [];
  bool _isLoading = false;

  List<Subject> get subjects => _subjects;
  bool get isLoading => _isLoading;

  Future<void> loadSubjects() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _subjects = await ContentService.fetchSubjects();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
