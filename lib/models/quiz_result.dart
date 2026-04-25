import 'package:uuid/uuid.dart';

class QuizResult {
  final String id;
  final String topic;
  final int score;
  final int total;
  final int timeTakenSeconds;
  final DateTime timestamp;

  QuizResult({
    String? id,
    required this.topic,
    required this.score,
    required this.total,
    required this.timeTakenSeconds,
    required this.timestamp,
  }) : id = id ?? const Uuid().v4();

  double get percentage => total > 0 ? score / total : 0.0;

  String get timeFormatted {
    final mins = timeTakenSeconds ~/ 60;
    final secs = timeTakenSeconds % 60;
    return '${mins}m ${secs.toString().padLeft(2, '0')}s';
  }

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
        id: json['id'] as String?,
        topic: json['topic'] as String? ?? '',
        score: json['score'] as int? ?? 0,
        total: json['total'] as int? ?? 1,
        timeTakenSeconds: json['timeTakenSeconds'] as int? ?? 0,
        timestamp:
            DateTime.tryParse(json['timestamp'] as String? ?? '') ??
                DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'score': score,
        'total': total,
        'timeTakenSeconds': timeTakenSeconds,
        'timestamp': timestamp.toIso8601String(),
      };
}
