import 'package:flutter/material.dart';
import '../models/mcq_model.dart';

class McqProvider with ChangeNotifier {
  List<McqQuestion> _questions = [];
  int _currentIndex = 0;
  Map<int, String> _userAnswers = {};
  bool _isFinished = false;

  List<McqQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  Map<int, String> get userAnswers => _userAnswers;
  bool get isFinished => _isFinished;

  McqQuestion? get currentQuestion => 
      _questions.isNotEmpty && _currentIndex < _questions.length 
      ? _questions[_currentIndex] 
      : null;

  double get progress => _questions.isEmpty ? 0 : (_currentIndex + 1) / _questions.length;

  void loadQuestions(List<McqQuestion> questions) {
    _questions = questions;
    _currentIndex = 0;
    _userAnswers = {};
    _isFinished = false;
    notifyListeners();
  }

  void selectOption(String optionId) {
    _userAnswers[_currentIndex] = optionId;
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      notifyListeners();
    } else {
      _isFinished = true;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
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
