import 'package:uuid/uuid.dart';
import 'chat_message.dart';

class ChatSession {
  final String id;
  String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  DateTime updatedAt;
  String lastTopic;

  ChatSession({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.lastTopic = '',
  })  : id = id ?? const Uuid().v4(),
        title = title ?? 'New Chat',
        messages = messages ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  void autoTitle() {
    if (messages.isNotEmpty && title == 'New Chat') {
      final firstUserMsg = messages.firstWhere((m) => m.isUser, orElse: () => messages.first);
      String content = firstUserMsg.content;
      if (content.length > 40) {
        title = '${content.substring(0, 37)}...';
      } else {
        title = content;
      }
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'messages': messages.map((m) => m.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'lastTopic': lastTopic,
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      title: json['title'],
      messages: (json['messages'] as List).map((m) => ChatMessage.fromJson(m)).toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastTopic: json['lastTopic'] ?? '',
    );
  }
}
