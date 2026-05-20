import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/chat_message_model.dart';
import '../models/soil_model.dart';
import '../models/weather_model.dart';
import '../services/ai_chat_service.dart';
import '../services/offline_cache_service.dart';

class ChatProvider extends ChangeNotifier {
  final AiChatService _service = AiChatService();
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  final List<ChatMessage> _messages = [];
  bool _typing = false;
  String _streamingContent = '';
  String _streamingUid = '';
  String _streamingLang = 'en';
  StreamSubscription<String>? _streamSub;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get typing => _typing;
  String get streamingContent => _streamingContent;

  void loadCached(String uid) {
    final cached = OfflineCacheService.getCachedMessages();
    _messages.clear();
    _messages.addAll(cached.map((m) => ChatMessage(
          id: m['id'] ?? '',
          uid: uid,
          role: m['role'] == 'user' ? MessageRole.user : MessageRole.assistant,
          content: m['content'] ?? '',
          language: m['language'] ?? 'en',
          timestamp: DateTime.tryParse(m['timestamp'] ?? '') ?? DateTime.now(),
        )));
    notifyListeners();
  }

  Future<void> sendMessage({
    required String uid,
    required String text,
    required String language,
    WeatherModel? weather,
    SoilModel? soil,
    String farmerName = '',
    String cropName = '',
    bool conciseResponses = true,
  }) async {
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      uid: uid,
      role: MessageRole.user,
      content: text,
      language: language,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    _typing = true;
    _streamingContent = '';
    _streamingUid = uid;
    _streamingLang = language;
    notifyListeners();

    _cacheMessage(userMsg);
    _saveToFirestore(uid, userMsg);

    // Pass history without the current message (service appends it)
    final history = _messages.sublist(0, _messages.length - 1);

    final stream = _service.sendMessageStream(
      message: text,
      language: language,
      history: history,
      weather: weather,
      soil: soil,
      farmerName: farmerName,
      cropName: cropName,
      conciseResponses: conciseResponses,
    );

    _streamSub = stream.listen(
      (word) {
        _streamingContent += word;
        notifyListeners();
      },
      onDone: _finishStreaming,
      onError: (_) => _finishStreaming(),
      cancelOnError: true,
    );
  }

  void _finishStreaming() {
    final content = _streamingContent.trim();
    if (content.isNotEmpty) {
      final aiMsg = ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}_ai',
        uid: _streamingUid,
        role: MessageRole.assistant,
        content: content,
        language: _streamingLang,
        timestamp: DateTime.now(),
      );
      _messages.add(aiMsg);
      _cacheMessage(aiMsg);
      _saveToFirestore(_streamingUid, aiMsg);
    }
    _streamingContent = '';
    _typing = false;
    notifyListeners();
  }

  void cancelStream() {
    _streamSub?.cancel();
    _streamSub = null;
    _finishStreaming();
  }

  void _cacheMessage(ChatMessage msg) {
    OfflineCacheService.cacheMessage({
      'id': msg.id,
      'uid': msg.uid,
      'role': msg.role.name,
      'content': msg.content,
      'language': msg.language,
      'timestamp': msg.timestamp.toIso8601String(),
    });
  }

  void _saveToFirestore(String uid, ChatMessage msg) {
    _db.collection('chatHistory').add(msg.toMap()).ignore();
  }

  void clearMessages() {
    _streamSub?.cancel();
    _streamSub = null;
    _messages.clear();
    _streamingContent = '';
    _typing = false;
    _service.clearHistory();
    notifyListeners();
  }
}
