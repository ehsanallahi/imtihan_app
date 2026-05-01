class User {
  final String id;
  final String name;
  final String email;
  final String? grade;
  final String? board;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.grade,
    this.board,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      grade: json['grade'],
      board: json['board'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'grade': grade,
      'board': board,
    };
  }
}

class UserStats {
  final int testsTaken;
  final int averageAccuracy;
  final int currentStreak;

  UserStats({
    required this.testsTaken,
    required this.averageAccuracy,
    required this.currentStreak,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      testsTaken: json['testsTaken'] ?? 0,
      averageAccuracy: json['averageAccuracy'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
    );
  }
}
