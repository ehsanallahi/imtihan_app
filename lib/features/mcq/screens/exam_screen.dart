import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/mcq_provider.dart';
import '../providers/exam_provider.dart';
import '../models/mcq_model.dart';
import 'results_screen.dart';

class ExamScreen extends StatelessWidget {
  const ExamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // We use the existing McqProvider but in "Exam Mode"
      ],
      child: Consumer2<McqProvider, ExamProvider>(
        builder: (context, mcqProvider, examProvider, child) {
          final question = mcqProvider.currentQuestion;
          
          if (question == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Handle auto-submission
          if (examProvider.currentSession?.isSubmitted ?? false) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _finishExam(context, mcqProvider);
            });
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(examProvider.currentSession?.title ?? 'Exam'),
              centerTitle: true,
              actions: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      examProvider.remainingTimeText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryCrimson,
                      ),
                    ),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4.0),
                child: LinearProgressIndicator(
                  value: examProvider.progress,
                  backgroundColor: AppColors.lightTeal,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryCrimson),
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, mcqProvider, examProvider),
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
                          final isSelected = mcqProvider.userAnswers[mcqProvider.currentIndex] == option.id;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GestureDetector(
                              onTap: () => mcqProvider.selectOption(option.id),
                              child: Container(
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
                                    _buildOptionIndicator(isSelected),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        option.text,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                      ],
                    ),
                  ),
                  _buildActionButtons(context, mcqProvider, examProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, McqProvider mcq, ExamProvider exam) {
    final question = mcq.currentQuestion!;
    final isFlagged = exam.isFlagged(question.id);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Question ${mcq.currentIndex + 1}/${mcq.questions.length}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
        ),
        IconButton(
          icon: Icon(
            isFlagged ? Icons.flag_rounded : Icons.flag_outline_rounded,
            color: isFlagged ? AppColors.primaryCrimson : AppColors.textSecondary,
          ),
          onPressed: () => exam.toggleFlag(question.id),
          tooltip: 'Flag for Review',
        ),
      ],
    );
  }

  Widget _buildOptionIndicator(bool isSelected) {
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

  Widget _buildActionButtons(BuildContext context, McqProvider mcq, ExamProvider exam) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: mcq.currentIndex > 0 ? mcq.previousQuestion : null,
          child: const Text('Previous'),
        ),
        Row(
          children: [
            TextButton(
              onPressed: () => _showReviewGrid(context, mcq, exam),
              child: const Text('Review All'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (mcq.currentIndex == mcq.questions.length - 1) {
                  _confirmSubmit(context, mcq, exam);
                } else {
                  mcq.nextQuestion();
                }
              },
              child: Text(mcq.currentIndex == mcq.questions.length - 1 ? 'Finish Exam' : 'Next'),
            ),
          ],
        ),
      ],
    );
  }

  void _showReviewGrid(BuildContext context, McqProvider mcq, ExamProvider exam) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Review Questions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: mcq.questions.length,
                itemBuilder: (context, index) {
                  final qId = mcq.questions[index].id;
                  final isAnswered = mcq.userAnswers.containsKey(index);
                  final isFlagged = exam.isFlagged(qId);
                  final isCurrent = mcq.currentIndex == index;

                  return GestureDetector(
                    onTap: () {
                      mcq.jumpToQuestion(index);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCurrent ? AppColors.primaryTeal : (isAnswered ? AppColors.lightTeal : Colors.white),
                        border: Border.all(
                          color: isFlagged ? AppColors.primaryCrimson : (isCurrent ? AppColors.primaryTeal : AppColors.border),
                          width: isFlagged || isCurrent ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isCurrent ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmSubmit(BuildContext context, McqProvider mcq, ExamProvider exam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish Exam?'),
        content: Text('You have answered ${mcq.userAnswers.length} out of ${mcq.questions.length} questions.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              exam.submitExam();
              _finishExam(context, mcq);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _finishExam(BuildContext context, McqProvider mcq) async {
    await mcq.finishAndSaveResults();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ResultsScreen(isExam: true)),
      );
    }
  }
}
