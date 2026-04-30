class McqQuestion {
  final String id;
  final String questionText;
  final List<McqOption> options;
  final String correctAnswerId;
  final String? explanation;

  McqQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerId,
    this.explanation,
  });
}

class McqOption {
  final String id;
  final String text;

  McqOption({
    required this.id,
    required this.text,
  });
}
