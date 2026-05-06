import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../../../core/services/content_service.dart';

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String? _language; // 'english' or 'urdu'
  bool _isLoadingHistory = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  String? get language => _language;
  bool get isLoadingHistory => _isLoadingHistory;

  ChatProvider() {
    _initializeChat();
  }

  void _initializeChat() {
    if (_messages.isEmpty) {
      _messages.add(ChatMessage(
        id: 'welcome',
        text: "Hello! I'm your Imtihan AI Tutor. Ask me anything about your subjects, MCQs, or exam preparation!",
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<void> loadHistory() async {
    _isLoadingHistory = true;
    notifyListeners();
    try {
      final history = await ContentService.fetchChatHistory();
      final List msgs = history['messages'] ?? [];
      _language = history['language'];
      
      _messages.clear();
      if (msgs.isNotEmpty) {
        for (var m in msgs) {
          _messages.add(ChatMessage(
            id: DateTime.now().toString() + m['content'].hashCode.toString(),
            text: m['content'],
            sender: (m['role'] == 'user' || m['role'] == 'student') 
                ? MessageSender.user 
                : MessageSender.ai,
            timestamp: DateTime.now(),
          ));
        }
      } else {
        _initializeChat();
      }
    } catch (e) {
      debugPrint('Error loading chat history: $e');
      _initializeChat();
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

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
      final recentMessages = _messages.where((m) => m.text.isNotEmpty).toList();
      final contextMessages = recentMessages.length > 10 
          ? recentMessages.sublist(recentMessages.length - 10) 
          : recentMessages;

      final chatHistory = contextMessages.map((m) => {
        'role': m.sender == MessageSender.user ? 'user' : 'assistant',
        'content': m.text,
      }).toList();

      final response = await ContentService.chatWithAi(chatHistory, language: _language ?? 'english');

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
    _initializeChat();
    notifyListeners();
  }
}
