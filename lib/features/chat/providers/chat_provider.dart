import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../models/chat_model.dart';
import '../../../core/services/content_service.dart';

class ChatProvider with ChangeNotifier {
  List<ChatMessage> _messages = [];
  List<Map<String, dynamic>> _sessions = [];
  String? _currentSessionId;
  bool _isLoading = false;
  String _currentLanguage = 'english';
  bool _isTyping = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  List<Map<String, dynamic>> get sessions => _sessions;
  String? get currentSessionId => _currentSessionId;
  bool get isLoading => _isLoading;
  String get currentLanguage => _currentLanguage;
  bool get isTyping => _isTyping;

  ChatProvider() {
    fetchSessions();
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

  Future<void> fetchSessions() async {
    try {
      final data = await ContentService.fetchChatSessions();
      _sessions = List<Map<String, dynamic>>.from(data['sessions']);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching sessions: $e');
    }
  }

  Future<void> loadSession(String sessionId) async {
    _currentSessionId = sessionId;
    _isLoading = true;
    _messages = [];
    notifyListeners();

    try {
      final data = await ContentService.fetchChatHistory(sessionId: sessionId);
      final List msgs = data['messages'] ?? [];
      _currentLanguage = data['language'] ?? 'english';
      
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
        text: 'Too many students are chatting now, please try later.',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  Future<void> clearChat() async {
    try {
      await ContentService.clearChatHistory();
      _messages.clear();
      _initializeChat();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing chat: $e');
      _messages.clear();
      _initializeChat();
      notifyListeners();
    }
  }

  // --- Voice Chat Logic ---
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  String _recognizedText = "";

  bool get isListening => _isListening;
  String get recognizedText => _recognizedText;

  Future<void> startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => debugPrint('STT Status: $status'),
      onError: (error) => debugPrint('STT Error: $error'),
    );

    if (available) {
      _isListening = true;
      notifyListeners();
      _speech.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords;
          notifyListeners();
        },
        localeId: _currentLanguage == 'urdu' ? 'ur_PK' : 'en_US',
      );
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
    notifyListeners();
  }

  Future<void> speak(String text) async {
    await _tts.setLanguage(_currentLanguage == 'urdu' ? 'ur-PK' : 'en-US');
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }
}
