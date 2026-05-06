import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/mcq_provider.dart';
import '../../../core/services/content_service.dart';

class ResultsScreen extends StatefulWidget {
  final bool isExam;
  const ResultsScreen({super.key, this.isExam = false});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String? _aiAnalysis;
  bool _isLoadingAnalysis = false;

  Future<void> _getAiAnalysis() async {
    setState(() => _isLoadingAnalysis = true);
    try {
      final provider = context.read<McqProvider>();
      // Use the session ID if available, otherwise we can't analyze (should have one)
      final sessionId = provider.currentSessionId; 
      if (sessionId == null) {
        throw Exception('No session ID found for analysis');
      }
      
      final analysis = await ContentService.analyzePerformance(sessionId);
      setState(() => _aiAnalysis = analysis);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting AI analysis: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingAnalysis = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<McqProvider>();
    final score = provider.score;
    final total = provider.questions.length;
    final percentage = (score / total * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isExam ? 'Exam Results' : 'Practice Results'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildScoreCircle(context, percentage, score, total),
              const SizedBox(height: 32),
              _buildStatsRow(context, provider),
              const SizedBox(height: 24),
              _buildAiAnalysisSection(),
              const SizedBox(height: 40),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiAnalysisSection() {
    if (_aiAnalysis != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primaryTeal.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryTeal.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology_rounded, color: AppColors.primaryTeal),
                const SizedBox(width: 12),
                Text(
                  'AI Performance Analysis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _aiAnalysis!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_isLoadingAnalysis)
          const Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('AI is analyzing your performance...'),
            ],
          )
        else
          OutlinedButton.icon(
            onPressed: _getAiAnalysis,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Analyze Performance with AI'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              side: const BorderSide(color: AppColors.primaryTeal),
              foregroundColor: AppColors.primaryTeal,
            ),
          ),
      ],
    );
  }

  Widget _buildScoreCircle(BuildContext context, int percentage, int score, int total) {
    Color color;
    String message;
    if (percentage >= 80) {
      color = AppColors.primaryTeal;
      message = 'Excellent Job!';
    } else if (percentage >= 50) {
      color = AppColors.primaryGold;
      message = 'Good Effort!';
    } else {
      color = AppColors.primaryCrimson;
      message = 'Keep Practicing!';
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 12,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$percentage%',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$score/$total Correct',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          message,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, McqProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatColumn(
            label: 'Accuracy',
            value: '${(provider.score / provider.questions.length * 100).round()}%',
            icon: Icons.track_changes,
            color: AppColors.primaryTeal,
          ),
          Container(width: 1, height: 40, color: AppColors.border),
          const _StatColumn(
            label: 'Time Taken',
            value: '4m 12s',
            icon: Icons.timer_outlined,
            color: AppColors.primaryGold,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: const Text('Back to Dashboard'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Go back to the practice screen
            // The practice screen should ideally reset
          },
          child: const Text('Review Questions'),
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
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
