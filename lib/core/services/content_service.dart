import 'dart:convert';
import '../services/api_service.dart';
import '../../features/mcq/models/subject_model.dart';
import '../../features/mcq/models/mcq_model.dart';

class ContentService {
  static Future<List<Subject>> fetchSubjects() async {
    final response = await ApiService.get('/subjects');
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Subject(
        id: json['id'],
        name: json['name'],
        icon: json['icon'] ?? '📚',
        chapters: (json['chapters'] as List).map((c) => Chapter(
          id: c['id'],
          name: c['name'],
          questionCount: c['_count']?['mcqs'] ?? 0,
        )).toList(),
      )).toList();
    }
    throw Exception('Failed to load subjects');
  }

  static Future<List<McqQuestion>> fetchChapterMcqs(String chapterId) async {
    final response = await ApiService.get('/chapters/$chapterId/mcqs');
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => McqQuestion(
        id: json['id'],
        questionText: json['question'],
        correctAnswerId: json['correctAnswer'],
        explanation: json['explanation'],
        options: [
          McqOption(id: 'A', text: json['optionA']),
          McqOption(id: 'B', text: json['optionB']),
          McqOption(id: 'C', text: json['optionC']),
          McqOption(id: 'D', text: json['optionD']),
        ],
      )).toList();
    }
    throw Exception('Failed to load MCQs');
  }

  static Future<void> saveQuizResults({
    required String chapterId,
    required int score,
    required int total,
  }) async {
    final response = await ApiService.post('/progress', {
      'chapterId': chapterId,
      'score': score,
      'total': total,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to save progress');
    }
  }
}
