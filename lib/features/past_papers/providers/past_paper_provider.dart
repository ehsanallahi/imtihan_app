import 'package:flutter/material.dart';
import '../models/past_paper_model.dart';
import '../../../core/services/content_service.dart';

class PastPaperProvider with ChangeNotifier {
  List<PastPaper> _allPapers = [];
  bool _isLoading = false;
  String? _error;

  // Fallback mock data used if API fails
  static final List<PastPaper> _mockPapers = [
    PastPaper(id: '1', title: 'Biology - Group 1', board: 'Lahore Board', year: '2023', grade: '10th', subject: 'Biology'),
    PastPaper(id: '2', title: 'Chemistry - Group 2', board: 'Federal Board', year: '2022', grade: '9th', subject: 'Chemistry'),
    PastPaper(id: '3', title: 'Physics - Group 1', board: 'Karachi Board', year: '2023', grade: '12th', subject: 'Physics'),
    PastPaper(id: '4', title: 'Mathematics - Group 1', board: 'Lahore Board', year: '2021', grade: '10th', subject: 'Math'),
    PastPaper(id: '5', title: 'Computer Science', board: 'KPK Board', year: '2022', grade: '11th', subject: 'CS'),
  ];

  String _selectedBoard = 'All';
  String _selectedYear = 'All';

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<String> get boards => ['All', 'Lahore Board', 'Federal Board', 'Karachi Board', 'KPK Board', 'Sindh Board'];
  List<String> get years => ['All', '2023', '2022', '2021', '2020'];

  String get selectedBoard => _selectedBoard;
  String get selectedYear => _selectedYear;

  List<PastPaper> get filteredPapers {
    return _allPapers.where((paper) {
      final boardMatch = _selectedBoard == 'All' || paper.board == _selectedBoard;
      final yearMatch = _selectedYear == 'All' || paper.year == _selectedYear;
      return boardMatch && yearMatch;
    }).toList();
  }

  Future<void> loadPapers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allPapers = await ContentService.fetchPastPapers();
    } catch (e) {
      debugPrint('Failed to load past papers from API, using fallback: $e');
      _allPapers = _mockPapers;
      _error = null; // Don't show error to user when fallback works
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setBoard(String board) {
    _selectedBoard = board;
    notifyListeners();
  }

  void setYear(String year) {
    _selectedYear = year;
    notifyListeners();
  }
}
