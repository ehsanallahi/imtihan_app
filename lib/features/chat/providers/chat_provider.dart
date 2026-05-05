import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../../../core/services/content_service.dart';

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1',
      text: "Hello! I'm your Imtihan AI Tutor powered by Groq. Ask me anything about your subjects, MCQs, or exam preparation!",
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
    ),
  ];

  bool _isTyping = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().toString(),
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _isTyping = true;
    notifyListeners();

    // Call Groq API
    _getAiResponse();
  }

  Future<void> _getAiResponse() async {
    try {
      // Build conversation history for context (last 10 messages to keep it manageable)
      final recentMessages = _messages
          .where((m) => m.text.isNotEmpty)
          .toList();
      
      // Take only last 10 messages for context window
      final contextMessages = recentMessages.length > 10 
          ? recentMessages.sublist(recentMessages.length - 10) 
          : recentMessages;

      final chatHistory = contextMessages.map((m) => {
        'role': m.sender == MessageSender.user ? 'user' : 'assistant',
        'content': m.text,
      }).toList();

      final response = await ContentService.chatWithAi(chatHistory);

      final aiMessage = ChatMessage(
        id: DateTime.now().toString(),
        text: response,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      );

      _messages.add(aiMessage);
    } catch (e) {
      debugPrint('ChatProvider error: $e');
      _messages.add(ChatMessage(
        id: DateTime.now().toString(),
        text: 'Sorry, I encountered an error. Please try again.',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _messages.add(ChatMessage(
      id: '1',
      text: "Hello! I'm your Imtihan AI Tutor powered by Groq. Ask me anything about your subjects, MCQs, or exam preparation!",
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }
}
