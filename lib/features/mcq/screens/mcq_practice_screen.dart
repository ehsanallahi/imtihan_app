import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/mcq_provider.dart';
import '../models/mcq_model.dart';

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
                Text(
                  'Question ${provider.currentIndex + 1}/${provider.questions.length}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  question.questionText,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView.separated(
                    itemCount: question.options.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final option = question.options[index];
                      final isSelected = provider.userAnswers[provider.currentIndex] == option.id;

                      return GestureDetector(
                        onTap: () => provider.selectOption(option.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.lightTeal : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryTeal : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primaryTeal : AppColors.textSecondary,
                                  ),
                                  color: isSelected ? AppColors.primaryTeal : Colors.transparent,
                                ),
                                child: isSelected 
                                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                                  : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option.text,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: isSelected ? AppColors.darkTeal : AppColors.textPrimary,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (provider.currentIndex > 0)
                      TextButton(
                        onPressed: provider.previousQuestion,
                        child: const Text('Previous'),
                      )
                    else
                      const SizedBox.shrink(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(120, 50),
                      ),
                      onPressed: provider.userAnswers[provider.currentIndex] != null
                        ? () {
                            if (provider.currentIndex == provider.questions.length - 1) {
                              _showResults(context, provider);
                            } else {
                              provider.nextQuestion();
                            }
                          }
                        : null,
                      child: Text(
                        provider.currentIndex == provider.questions.length - 1 
                          ? 'Finish' 
                          : 'Next'
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showResults(BuildContext context, McqProvider provider) {
    // Navigate to results screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Completed!'),
        content: Text('You scored ${provider.score} out of ${provider.questions.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Go Home'),
          ),
        ],
      ),
    );
  }
}
