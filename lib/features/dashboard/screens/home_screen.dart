import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../mcq/models/mcq_model.dart';
import '../../mcq/providers/mcq_provider.dart';
import '../../mcq/screens/mcq_practice_screen.dart';
import '../../auth/providers/user_provider.dart';
import '../../../core/services/content_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../chat/screens/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        final stats = userProvider.stats;
        final recentChapter = userProvider.recentChapter;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  '${context.l10n('hello_student').replaceFirst('Student', user?.name ?? 'Student')}',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                Text(
                  context.l10n('ready_to_practice'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Quick Action Card (Continue Learning)
                _buildActionCard(
                  context,
                  title: recentChapter != null ? context.l10n('continue_learning') : context.l10n('start_mcq'),
                  subtitle: recentChapter != null 
                    ? '${context.l10n('resume')} ${recentChapter.name}' 
                    : context.l10n('select_subject'),
                  icon: Icons.play_arrow_rounded,
                  color: AppColors.primaryTeal,
                  onTap: () {
                    if (recentChapter != null) {
                      _resumeChapter(context, recentChapter.id);
                    } else {
                      // Navigate to Practice Hub (handled by Shell)
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                _buildActionCard(
                  context,
                  title: context.l10n('ai_tutor'),
                  subtitle: 'Ask questions about any topic',
                  icon: Icons.psychology_rounded,
                  color: AppColors.primaryGold,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatScreen()),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                Text(
                  context.l10n('recent_progress'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(label: context.l10n('tests'), value: '${stats?.testsTaken ?? 0}'),
                      _StatItem(label: context.l10n('correct'), value: '${stats?.averageAccuracy.toStringAsFixed(0) ?? 0}%'),
                      _StatItem(label: context.l10n('streak'), value: '${stats?.currentStreak ?? 0} ${context.l10n('days')}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resumeChapter(BuildContext context, String chapterId) async {
    final mcqProvider = Provider.of<McqProvider>(context, listen: false);
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final questions = await ContentService.fetchChapterMcqs(chapterId);
      mcqProvider.loadQuestions(questions);
      mcqProvider.setCurrentChapter(chapterId);
      
      if (context.mounted) {
        Navigator.pop(context); // Remove loading
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const McqPracticeScreen()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Remove loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading MCQs: $e')),
        );
      }
    }
  }

  void _startPractice(BuildContext context) {
    // This is now replaced by _resumeChapter or handled by the Practice Hub navigation
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryTeal,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
