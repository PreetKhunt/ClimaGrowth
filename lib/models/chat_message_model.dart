import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageRole { user, assistant }

class ChatMessage {
  final String id;
  final String uid;
  final MessageRole role;
  final String content;
  final String language;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.uid,
    required this.role,
    required this.content,
    required this.language,
    required this.timestamp,
  });

  bool get isUser => role == MessageRole.user;

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    return ChatMessage(
      id: id,
      uid: map['uid'] ?? '',
      role: map['role'] == 'user' ? MessageRole.user : MessageRole.assistant,
      content: map['content'] ?? map['answer'] ?? map['question'] ?? '',
      language: map['language'] ?? 'en',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'role': role.name,
        'content': content,
        'language': language,
        'timestamp': Timestamp.fromDate(timestamp),
      };
}
