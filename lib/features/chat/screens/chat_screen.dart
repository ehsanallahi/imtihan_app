import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/chat_provider.dart';
import '../models/chat_model.dart';

class ChatScreen extends StatefulWidget {
  final String? initialMessage;
  const ChatScreen({super.key, this.initialMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ChatProvider>();
      // Only send initial message if language is already known
      if (widget.initialMessage != null && provider.language != null) {
        provider.sendMessage(widget.initialMessage!);
      }
    });
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              context.read<ChatProvider>().clearChat();
            },
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingHistory) {
                  return const Center(child: CircularProgressIndicator());
                }

                _scrollToBottom();
                return Stack(
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.messages.length + (provider.isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == provider.messages.length && provider.isTyping) {
                          return const _TypingIndicator();
                        }
                        final message = provider.messages[index];
                        return _ChatBubble(message: message);
                      },
                    ),
                    if (provider.language == null)
                      _buildLanguageSelection(context, provider),
                  ],
                );
              },
            ),
          ),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildLanguageSelection(BuildContext context, ChatProvider provider) {
    return Container(
      color: Colors.white.withOpacity(0.9),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language_rounded, size: 48, color: AppColors.primaryTeal),
              const SizedBox(height: 16),
              const Text(
                'Choose Your Language',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selected language will be used for all conversations in this session.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        provider.setLanguage('english');
                        if (widget.initialMessage != null) {
                          provider.sendMessage(widget.initialMessage!);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('English'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        provider.setLanguage('urdu');
                        if (widget.initialMessage != null) {
                          provider.sendMessage(widget.initialMessage!);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('اردو (Urdu)'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, child) {
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
                IconButton(
                  icon: Icon(
                    provider.isListening ? Icons.mic : Icons.mic_none,
                    color: provider.isListening ? Colors.red : AppColors.primaryTeal,
                  ),
                  onPressed: () {
                    if (provider.isListening) {
                      provider.stopListening().then((_) {
                        if (provider.recognizedText.isNotEmpty) {
                          _controller.text = provider.recognizedText;
                        }
                      });
                    } else {
                      provider.startListening();
                    }
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: provider.isListening ? 'Listening...' : (provider.isTyping ? 'AI is thinking...' : 'Ask me anything...'),
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    enabled: !provider.isTyping,
                    onSubmitted: (value) {
                      if (!provider.isTyping && value.isNotEmpty) {
                        context.read<ChatProvider>().sendMessage(value);
                        _controller.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: provider.isTyping ? null : () {
                    context.read<ChatProvider>().sendMessage(_controller.text);
                    _controller.clear();
                  },
                  icon: Icon(
                    Icons.send_rounded, 
                    color: provider.isTyping ? AppColors.textSecondary : AppColors.primaryTeal,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: provider.isTyping ? Colors.grey[200] : AppColors.lightTeal,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryGold.withOpacity(0.2),
            radius: 16,
            child: const Icon(Icons.psychology, color: AppColors.darkGold, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final value = (_controller.value - delay).clamp(0.0, 1.0);
                    final opacity = (0.3 + 0.7 * (0.5 + 0.5 * sin(value * pi * 2))).clamp(0.3, 1.0);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.textSecondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isAi 
                      ? MarkdownBody(
                          data: message.text,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              height: 1.4,
                            ),
                            strong: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      : SelectableText(
                          message.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                    if (isAi) ...[
                      const SizedBox(height: 8),
                      Consumer<ChatProvider>(
                        builder: (context, provider, child) {
                          final isSpeaking = provider.currentlySpeakingMessageId == message.id;
                          return GestureDetector(
                            onTap: () => provider.speak(message.id, message.text),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSpeaking ? Icons.stop_circle_outlined : Icons.volume_up_outlined,
                                  size: 16,
                                  color: isSpeaking ? Colors.red : AppColors.primaryTeal,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isSpeaking ? 'Stop' : 'Listen',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSpeaking ? Colors.red : AppColors.primaryTeal,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ],
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
