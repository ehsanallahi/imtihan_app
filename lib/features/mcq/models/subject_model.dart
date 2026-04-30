class Subject {
  final String id;
  final String name;
  final String icon;
  final List<Chapter> chapters;

  Subject({
    required this.id,
    required this.name,
    required this.icon,
    required this.chapters,
  });
}

class Chapter {
  final String id;
  final String name;
  final int questionCount;

  Chapter({
    required this.id,
    required this.name,
    required this.questionCount,
  });
}
