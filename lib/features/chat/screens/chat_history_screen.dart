import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Conversations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () => _showNewChatDialog(context),
            tooltip: 'Start New Chat',
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          if (provider.sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('No conversations yet'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _showNewChatDialog(context),
                    child: const Text('Start First Chat'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.sessions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final session = provider.sessions[index];
              final date = DateTime.parse(session['updatedAt']);
              
              return _buildSessionCard(context, session, date);
            },
          );
        },
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, Map<String, dynamic> session, DateTime date) {
    final provider = context.read<ChatProvider>();
    final isUrdu = session['language'] == 'urdu';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryTeal.withOpacity(0.1),
          child: Icon(
            isUrdu ? Icons.translate : Icons.psychology,
            color: AppColors.primaryTeal,
          ),
        ),
        title: Text(
          session['title'] ?? 'New Conversation',
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          DateFormat('MMM d, h:mm a').format(date),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          provider.loadSession(session['id']);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        },
      ),
    );
  }

  void _showNewChatDialog(BuildContext context) {
    final provider = context.read<ChatProvider>();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Language',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _LanguageOption(
                    title: 'English',
                    icon: '🇺🇸',
                    onTap: () {
                      provider.createNewChat('english');
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _LanguageOption(
                    title: 'اردو',
                    icon: '🇵🇰',
                    onTap: () {
                      provider.createNewChat('urdu');
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;

  const _LanguageOption({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
