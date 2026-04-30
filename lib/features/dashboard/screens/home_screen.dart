import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../mcq/models/mcq_model.dart';
import '../../mcq/providers/mcq_provider.dart';
import '../../mcq/screens/mcq_practice_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Hello, Student!',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            Text(
              'Ready to practice today?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            
            // Quick Action Card
            _buildActionCard(
              context,
              title: 'Start MCQ Practice',
              subtitle: '20 Questions from Biology Chapter 1',
              icon: Icons.play_arrow_rounded,
              color: AppColors.primaryTeal,
              onTap: () => _startPractice(context),
            ),
            
            const SizedBox(height: 16),
            
            _buildActionCard(
              context,
              title: 'AI Tutor',
              subtitle: 'Ask questions about any topic',
              icon: Icons.psychology_rounded,
              color: AppColors.primaryGold,
              onTap: () {},
            ),
            
            const SizedBox(height: 32),
            Text(
              'Recent Progress',
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(label: 'Tests', value: '12'),
                  _StatItem(label: 'Correct', value: '85%'),
                  _StatItem(label: 'Streak', value: '4 days'),
                ],
              ),
            ),
          ],
        ),
      ),
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

  void _startPractice(BuildContext context) {
    final provider = Provider.of<McqProvider>(context, listen: false);
    
    // Mock Data
    final mockQuestions = [
      McqQuestion(
        id: '1',
        questionText: 'What is the primary function of Mitochondria?',
        options: [
          McqOption(id: 'a', text: 'Protein Synthesis'),
          McqOption(id: 'b', text: 'Energy Production (ATP)'),
          McqOption(id: 'c', text: 'Waste Disposal'),
          McqOption(id: 'd', text: 'DNA Replication'),
        ],
        correctAnswerId: 'b',
      ),
      McqQuestion(
        id: '2',
        questionText: 'Which gas is released during photosynthesis?',
        options: [
          McqOption(id: 'a', text: 'Carbon Dioxide'),
          McqOption(id: 'b', text: 'Nitrogen'),
          McqOption(id: 'c', text: 'Oxygen'),
          McqOption(id: 'd', text: 'Hydrogen'),
        ],
        correctAnswerId: 'c',
      ),
    ];

    provider.loadQuestions(mockQuestions);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const McqPracticeScreen()),
    );
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
