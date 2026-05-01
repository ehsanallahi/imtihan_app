import 'dart:async';
import 'package:flutter/material.dart';
import '../models/exam_model.dart';

class ExamProvider with ChangeNotifier {
  ExamSession? _currentSession;
  Timer? _timer;
  final Set<String> _flaggedQuestionIds = {};

  ExamSession? get currentSession => _currentSession;
  Set<String> get flaggedQuestionIds => _flaggedQuestionIds;

  String get remainingTimeText {
    if (_currentSession == null) return '00:00';
    final remaining = _currentSession!.remainingTime;
    if (remaining.isNegative) return '00:00';
    
    final minutes = remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get progress {
    if (_currentSession == null) return 0;
    final elapsed = _currentSession!.elapsedTime.inSeconds;
    final total = _currentSession!.durationMinutes * 60;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  void startExam(String id, String title, int durationMinutes) {
    _currentSession = ExamSession(
      id: id,
      title: title,
      durationMinutes: durationMinutes,
      startTime: DateTime.now(),
    );
    _flaggedQuestionIds.clear();
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSession?.isTimeUp ?? false) {
        submitExam();
      } else {
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void toggleFlag(String questionId) {
    if (_flaggedQuestionIds.contains(questionId)) {
      _flaggedQuestionIds.remove(questionId);
    } else {
      _flaggedQuestionIds.add(questionId);
    }
    notifyListeners();
  }

  bool isFlagged(String questionId) => _flaggedQuestionIds.contains(questionId);

  void submitExam() {
    _timer?.cancel();
    _currentSession?.isSubmitted = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
