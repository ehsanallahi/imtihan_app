import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../models/subject_model.dart';
import '../models/mcq_model.dart';
import '../providers/mcq_provider.dart';
import 'mcq_practice_screen.dart';

class ChapterSelectionScreen extends StatelessWidget {
  final Subject subject;

  const ChapterSelectionScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${subject.name} Chapters'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: subject.chapters.length,
        itemBuilder: (context, index) {
          final chapter = subject.chapters[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                chapter.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${chapter.questionCount} Questions'),
              trailing: const Icon(Icons.play_circle_outline, color: AppColors.primaryTeal),
              onTap: () => _startPractice(context, chapter),
            ),
          );
        },
      ),
    );
  }

  void _startPractice(BuildContext context, Chapter chapter) async {
    final provider = Provider.of<McqProvider>(context, listen: false);
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await provider.loadChapterQuestions(chapter.id);
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const McqPracticeScreen()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load questions')),
        );
      }
    }
  }
}
