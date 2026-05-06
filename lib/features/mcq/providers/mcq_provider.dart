import 'package:flutter/material.dart';
import '../../../core/services/content_service.dart';
import '../models/mcq_model.dart';

class McqProvider with ChangeNotifier {
  List<McqQuestion> _questions = [];
  String? _currentChapterId;
  String? _currentSessionId;
  int _currentIndex = 0;
  Map<int, String> _userAnswers = {};
  bool _isFinished = false;
  bool _isCurrentAnswerSubmitted = false;

  List<McqQuestion> get questions => _questions;
  String? get currentChapterId => _currentChapterId;
  int get currentIndex => _currentIndex;
  Map<int, String> get userAnswers => _userAnswers;
  bool get isFinished => _isFinished;
  bool get isCurrentAnswerSubmitted => _isCurrentAnswerSubmitted;

  McqQuestion? get currentQuestion => 
      _questions.isNotEmpty && _currentIndex < _questions.length 
      ? _questions[_currentIndex] 
      : null;

  double get progress => _questions.isEmpty ? 0 : (_currentIndex + 1) / _questions.length;

  Future<void> loadChapterQuestions(String chapterId) async {
    _questions = [];
    _currentChapterId = chapterId;
    _isFinished = false;
    _isCurrentAnswerSubmitted = false;
    notifyListeners();
    
    try {
      _questions = await ContentService.fetchChapterMcqs(chapterId);
      _currentIndex = 0;
      _userAnswers = {};
    } catch (e) {
      // Handle error
    } finally {
      notifyListeners();
    }
  }

  void loadQuestions(List<McqQuestion> questions) {
    _questions = questions;
    _currentChapterId = null; // Mock or manual load
    _currentIndex = 0;
    _userAnswers = {};
    _isFinished = false;
    _isCurrentAnswerSubmitted = false;
    notifyListeners();
  }

  void selectOption(String optionId) {
    if (_isCurrentAnswerSubmitted) return;
    _userAnswers[_currentIndex] = optionId;
    notifyListeners();
  }

  void submitAnswer() {
    if (_userAnswers.containsKey(_currentIndex)) {
      _isCurrentAnswerSubmitted = true;
      notifyListeners();
    }
  }

  Future<void> finishAndSaveResults() async {
    _isFinished = true;
    notifyListeners();
    
    if (_currentChapterId != null || _currentSessionId != null) {
      try {
        await ContentService.saveQuizResults(
          chapterId: _currentChapterId,
          sessionId: _currentSessionId,
          score: score,
          total: _questions.length,
        );
      } catch (e) {
        debugPrint('Failed to save progress: $e');
      }
    }
  }

  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      _isCurrentAnswerSubmitted = false;
      notifyListeners();
    } else {
      _isFinished = true;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      // When going back, we might want to show the answer they previously submitted
      _isCurrentAnswerSubmitted = _userAnswers.containsKey(_currentIndex);
      notifyListeners();
    }
  }

  void jumpToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentIndex = index;
      _isCurrentAnswerSubmitted = _userAnswers.containsKey(_currentIndex);
      notifyListeners();
    }
  }

  void setCurrentChapter(String chapterId) {
    _currentChapterId = chapterId;
    notifyListeners();
  }

  int get score {
    int count = 0;
    _userAnswers.forEach((index, selectedId) {
      if (_questions[index].correctAnswerId == selectedId) {
        count++;
      }
    });
    return count;
  }
}
