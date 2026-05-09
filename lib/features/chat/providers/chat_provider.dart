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
  String? _currentlySpeakingMessageId;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  List<Map<String, dynamic>> get sessions => _sessions;
  String? get currentSessionId => _currentSessionId;
  bool get isLoading => _isLoading;
  bool get isLoadingHistory => _isLoading; // Alias
  String get currentLanguage => _currentLanguage;
  String? get language => _currentLanguage; // Alias
  bool get isTyping => _isTyping;
  String? get currentlySpeakingMessageId => _currentlySpeakingMessageId;

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

  void setLanguage(String lang) {
    _currentLanguage = lang;
    notifyListeners();
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
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createNewChat(String language) async {
    try {
      final data = await ContentService.createNewChat(language);
      final newSession = data['session'];
      _currentSessionId = newSession['id'];
      _messages = [];
      _currentLanguage = language;
      await fetchSessions();
      _initializeChat();
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating new chat: $e');
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    // Add student message
    _messages.add(ChatMessage(
      id: DateTime.now().toString(),
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    ));
    _isTyping = true;
    notifyListeners();

    try {
      final response = await ContentService.chatWithAi(
        _messages.map((m) => {
          'role': m.sender == MessageSender.user ? 'student' : 'ai',
          'content': m.text
        }).toList(),
        language: _currentLanguage,
        chatId: _currentSessionId,
      );
      
      _messages.add(ChatMessage(
        id: DateTime.now().toString(),
        text: response,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      debugPrint('Error sending message: $e');
      String errorMessage = 'Failed to reach AI Tutor. Please try again.';
      if (e.toString().contains('Failed to reach AI Tutor')) {
        errorMessage = 'AI service is currently unavailable. Please check your internet or try again later.';
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }
      
      _messages.add(ChatMessage(
        id: DateTime.now().toString(),
        text: errorMessage,
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

  Future<void> speak(String messageId, String text) async {
    if (_currentlySpeakingMessageId == messageId) {
      await stopSpeaking();
      return;
    }

    await stopSpeaking();
    _currentlySpeakingMessageId = messageId;
    notifyListeners();

    await _tts.setLanguage(_currentLanguage == 'urdu' ? 'ur-PK' : 'en-US');
    await _tts.setPitch(1.0);
    
    _tts.setCompletionHandler(() {
      _currentlySpeakingMessageId = null;
      notifyListeners();
    });

    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
    _currentlySpeakingMessageId = null;
    notifyListeners();
  }
}
