enum ModelUsed { localE2B, remoteE2B, none }

class ChatMessage {
  final String content;
  final bool isUser;
  final ModelUsed modelUsed;
  final int? latencyMs;
  final DateTime timestamp;
  final String? imageBase64;

  ChatMessage({
    required this.content,
    required this.isUser,
    this.modelUsed = ModelUsed.none,
    this.latencyMs,
    DateTime? timestamp,
    this.imageBase64,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'content': content,
    'isUser': isUser,
    'modelUsed': modelUsed.index,
    'latencyMs': latencyMs,
    'timestamp': timestamp.toIso8601String(),
    'imageBase64': imageBase64,
  };

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      content: json['content'],
      isUser: json['isUser'],
      modelUsed: ModelUsed.values[(json['modelUsed'] as int?)?.clamp(0, ModelUsed.values.length - 1) ?? 2],
      latencyMs: json['latencyMs'] as int?,
      timestamp: _parseDate(json['timestamp']),
      imageBase64: json['imageBase64'] as String?,
    );
  }
}
