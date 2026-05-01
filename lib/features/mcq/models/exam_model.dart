class ExamSession {
  final String id;
  final String title;
  final int durationMinutes;
  final DateTime startTime;
  final Set<String> flaggedQuestionIds;
  bool isSubmitted;

  ExamSession({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.startTime,
    this.flaggedQuestionIds = const {},
    this.isSubmitted = false,
  });

  Duration get elapsedTime => DateTime.now().difference(startTime);
  Duration get remainingTime => Duration(minutes: durationMinutes) - elapsedTime;
  bool get isTimeUp => elapsedTime.inMinutes >= durationMinutes;
}
