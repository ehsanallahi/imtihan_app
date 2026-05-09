class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? grade;
  final String? board;
  final String? medium;
  final String? role;
  final bool isPremium;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.grade,
    this.board,
    this.medium,
    this.role,
    this.isPremium = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatar'],
      grade: json['grade'],
      board: json['board'],
      medium: json['medium'],
      role: json['role'],
      isPremium: json['isPremium'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatarUrl,
      'grade': grade,
      'board': board,
      'medium': medium,
      'role': role,
      'isPremium': isPremium,
    };
  }
}

class UserStats {
  final int testsTaken;
  final double averageAccuracy;
  final int currentStreak;

  UserStats({
    required this.testsTaken,
    required this.averageAccuracy,
    required this.currentStreak,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      testsTaken: json['testsTaken'] ?? 0,
      averageAccuracy: (json['averageAccuracy'] ?? 0).toDouble(),
      currentStreak: json['studyStreak'] ?? 0,
    );
  }
}
