import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/mcq_provider.dart';
import '../models/mcq_model.dart';
import 'results_screen.dart';
import '../../chat/screens/chat_screen.dart';
import '../../auth/providers/user_provider.dart';

class McqPracticeScreen extends StatelessWidget {
  const McqPracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<McqProvider>(
      builder: (context, provider, child) {
        final question = provider.currentQuestion;
        
        if (question == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('MCQ Practice'),
            actions: [
              IconButton(
                icon: const Icon(Icons.psychology_outlined),
                onPressed: () => _openAiTutor(context, question),
                tooltip: 'Ask AI Tutor',
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: LinearProgressIndicator(
                value: provider.progress,
                backgroundColor: AppColors.lightTeal,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${provider.currentIndex + 1}/${provider.questions.length}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (provider.isCurrentAnswerSubmitted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: provider.userAnswers[provider.currentIndex] == question.correctAnswerId
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          provider.userAnswers[provider.currentIndex] == question.correctAnswerId
                              ? 'CORRECT'
                              : 'INCORRECT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: provider.userAnswers[provider.currentIndex] == question.correctAnswerId
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  question.questionText,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    children: [
                      ...question.options.map((option) {
                        final isSelected = provider.userAnswers[provider.currentIndex] == option.id;
                        final isCorrect = option.id == question.correctAnswerId;
                        final isSubmitted = provider.isCurrentAnswerSubmitted;

                        Color backgroundColor = Colors.white;
                        Color borderColor = AppColors.border;
                        if (isSelected) {
                          if (isSubmitted) {
                            backgroundColor = isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1);
                            borderColor = isCorrect ? Colors.green : Colors.red;
                          } else {
                            backgroundColor = AppColors.lightTeal;
                            borderColor = AppColors.primaryTeal;
                          }
                        } else if (isSubmitted && isCorrect) {
                          backgroundColor = Colors.green.withOpacity(0.05);
                          borderColor = Colors.green.withOpacity(0.5);
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: GestureDetector(
                            onTap: () => provider.selectOption(option.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: borderColor,
                                  width: isSelected || (isSubmitted && isCorrect) ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  _buildOptionIndicator(isSelected, isSubmitted, isCorrect),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      option.text,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: isSelected && isSubmitted
                                            ? (isCorrect ? Colors.green[900] : Colors.red[900])
                                            : AppColors.textPrimary,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      if (provider.isCurrentAnswerSubmitted && question.explanation != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.lightGold,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.lightbulb_outline, color: AppColors.darkGold, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Explanation',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkGold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                question.explanation!,
                                style: const TextStyle(color: AppColors.textPrimary, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildActionButtons(context, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionIndicator(bool isSelected, bool isSubmitted, bool isCorrect) {
    if (isSubmitted) {
      if (isCorrect) {
        return const Icon(Icons.check_circle, color: Colors.green, size: 24);
      }
      if (isSelected && !isCorrect) {
        return const Icon(Icons.cancel, color: Colors.red, size: 24);
      }
    }
    
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primaryTeal : AppColors.textSecondary,
          width: 2,
        ),
        color: isSelected ? AppColors.primaryTeal : Colors.transparent,
      ),
      child: isSelected 
        ? const Icon(Icons.check, size: 16, color: Colors.white)
        : null,
    );
  }

  Widget _buildActionButtons(BuildContext context, McqProvider provider) {
    final hasAnswered = provider.userAnswers.containsKey(provider.currentIndex);
    final isSubmitted = provider.isCurrentAnswerSubmitted;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (provider.currentIndex > 0)
          TextButton(
            onPressed: provider.previousQuestion,
            child: const Text('Previous'),
          )
        else
          const SizedBox.shrink(),
        
        if (!isSubmitted)
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(140, 50)),
            onPressed: hasAnswered ? () => provider.submitAnswer() : null,
            child: const Text('Check Answer'),
          )
        else
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(140, 50)),
            onPressed: () async {
              if (provider.currentIndex == provider.questions.length - 1) {
                await provider.finishAndSaveResults();
                if (context.mounted) {
                  // Refresh statistics for realtime updates on home screen
                  Provider.of<UserProvider>(context, listen: false).fetchStats();
                  Provider.of<UserProvider>(context, listen: false).fetchRecentChapter();
                  _showResults(context, provider);
                }
              } else {
                provider.nextQuestion();
              }
            },
            child: Text(
              provider.currentIndex == provider.questions.length - 1 
                ? 'See Results' 
                : 'Next Question'
            ),
          ),
      ],
    );
  }

  void _openAiTutor(BuildContext context, McqQuestion question) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          initialMessage: 'I need help with this question: "${question.questionText}"',
        ),
      ),
    );
  }

  void _showResults(BuildContext context, McqProvider provider) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ResultsScreen()),
    );
  }
}
