import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/past_paper_provider.dart';
import '../models/past_paper_model.dart';
import '../../mcq/providers/exam_provider.dart';
import '../../mcq/providers/mcq_provider.dart';
import '../../mcq/screens/exam_screen.dart';
import '../../../core/services/content_service.dart';

class PastPaperListScreen extends StatefulWidget {
  const PastPaperListScreen({super.key});

  @override
  State<PastPaperListScreen> createState() => _PastPaperListScreenState();
}

class _PastPaperListScreenState extends State<PastPaperListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PastPaperProvider>().loadPapers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Paper Bank'),
      ),
      body: Column(
        children: [
          _buildFilters(context),
          Expanded(
            child: Consumer<PastPaperProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final papers = provider.filteredPapers;

                if (papers.isEmpty) {
                  return const Center(
                    child: Text('No papers found matching filters'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: papers.length,
                  itemBuilder: (context, index) {
                    final paper = papers[index];
                    return _PastPaperCard(paper: paper);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Consumer<PastPaperProvider>(
      builder: (context, provider, child) {
        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _FilterChip(
                label: 'Board: ${provider.selectedBoard}',
                onTap: () => _showFilterDialog(
                  context,
                  title: 'Select Board',
                  options: provider.boards,
                  selected: provider.selectedBoard,
                  onSelected: provider.setBoard,
                ),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Year: ${provider.selectedYear}',
                onTap: () => _showFilterDialog(
                  context,
                  title: 'Select Year',
                  options: provider.years,
                  selected: provider.selectedYear,
                  onSelected: provider.setYear,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterDialog(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String selected,
    required Function(String) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  return ListTile(
                    title: Text(option),
                    trailing: option == selected 
                      ? const Icon(Icons.check, color: AppColors.primaryTeal)
                      : null,
                    onTap: () {
                      onSelected(option);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PastPaperCard extends StatelessWidget {
  final PastPaper paper;

  const _PastPaperCard({required this.paper});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.lightTeal,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.description_outlined, color: AppColors.primaryTeal),
        ),
        title: Text(
          paper.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${paper.board} • ${paper.year}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                paper.subject,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.darkGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _startExam(context),
      ),
    );
  }

  Future<void> _startExam(BuildContext context) async {
    final mcqProvider = Provider.of<McqProvider>(context, listen: false);
    final examProvider = Provider.of<ExamProvider>(context, listen: false);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final questions = await ContentService.fetchPastPaperMcqs(paper.id);
      
      mcqProvider.loadQuestions(questions);
      mcqProvider.setCurrentChapter(paper.id); // Tag results with paper ID
      
      examProvider.startExam(paper.id, paper.title, 40); // Standard 40 min exam

      if (context.mounted) {
        Navigator.pop(context); // Remove loading
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExamScreen()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Remove loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading paper: $e')),
        );
      }
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppColors.lightTeal,
      labelStyle: const TextStyle(color: AppColors.darkTeal, fontWeight: FontWeight.w600),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
