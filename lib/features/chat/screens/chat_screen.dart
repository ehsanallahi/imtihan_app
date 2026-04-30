import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/chat_provider.dart';
import '../models/chat_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology, color: AppColors.darkGold, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('AI Tutor'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                _scrollToBottom();
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    return _ChatBubble(message: message);
                  },
                );
              },
            ),
          ),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Ask me anything...',
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onSubmitted: (value) {
                  context.read<ChatProvider>().sendMessage(value);
                  _controller.clear();
                },
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () {
                context.read<ChatProvider>().sendMessage(_controller.text);
                _controller.clear();
              },
              icon: const Icon(Icons.send_rounded, color: AppColors.primaryTeal),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.lightTeal,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isAi = message.sender == MessageSender.ai;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAi) ...[
            CircleAvatar(
              backgroundColor: AppColors.primaryGold.withOpacity(0.2),
              radius: 16,
              child: const Icon(Icons.psychology, color: AppColors.darkGold, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isAi ? Colors.grey[100] : AppColors.primaryTeal,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isAi ? 0 : 16),
                  bottomRight: Radius.circular(isAi ? 16 : 0),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isAi ? AppColors.textPrimary : Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          if (!isAi) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              backgroundColor: AppColors.lightTeal,
              radius: 16,
              child: Icon(Icons.person, color: AppColors.primaryTeal, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}
