class StudyPlan {
  final String topic;
  final List<String> steps;
  final DateTime startDate;

  StudyPlan({
    required this.topic,
    required this.steps,
    required this.startDate,
  });

  factory StudyPlan.fromJson(Map<String, dynamic> json) {
    return StudyPlan(
      topic: json['topic'] ?? '',
      steps: List<String>.from(json['steps'] ?? []),
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'topic': topic,
    'steps': steps,
    'startDate': startDate.toIso8601String(),
  };
}
