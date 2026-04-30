import 'package:flutter/material.dart';
import '../models/subject_model.dart';

class SubjectProvider with ChangeNotifier {
  final List<Subject> _subjects = [
    Subject(
      id: '1',
      name: 'Biology',
      icon: '🧬',
      chapters: [
        Chapter(id: '101', name: 'Cell Biology', questionCount: 20),
        Chapter(id: '102', name: 'Genetics', questionCount: 15),
        Chapter(id: '103', name: 'Ecology', questionCount: 25),
      ],
    ),
    Subject(
      id: '2',
      name: 'Chemistry',
      icon: '🧪',
      chapters: [
        Chapter(id: '201', name: 'Organic Chemistry', questionCount: 30),
        Chapter(id: '202', name: 'Atomic Structure', questionCount: 20),
      ],
    ),
    Subject(
      id: '3',
      name: 'Physics',
      icon: '⚡',
      chapters: [
        Chapter(id: '301', name: 'Thermodynamics', questionCount: 18),
        Chapter(id: '302', name: 'Nuclear Physics', questionCount: 22),
      ],
    ),
    Subject(
      id: '4',
      name: 'Computer Science',
      icon: '💻',
      chapters: [
        Chapter(id: '401', name: 'Logic Gates', questionCount: 12),
        Chapter(id: '402', name: 'Networking', questionCount: 20),
      ],
    ),
  ];

  List<Subject> get subjects => _subjects;
}
