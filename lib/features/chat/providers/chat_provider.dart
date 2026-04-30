import 'package:flutter/material.dart';
import '../models/chat_model.dart';

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1',
      text: "Hello! I'm your Imtihan AI Tutor. How can I help you today?",
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
    ),
  ];

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().toString(),
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    notifyListeners();

    // Simulate AI Response
    _simulateAiResponse(text);
  }

  void _simulateAiResponse(String userText) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final aiMessage = ChatMessage(
      id: DateTime.now().toString(),
      text: "I'm processing your request about '$userText'. In a real app, I would provide a detailed explanation here!",
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
    );

    _messages.add(aiMessage);
    notifyListeners();
  }
}
