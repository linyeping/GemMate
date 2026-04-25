import 'package:flutter/material.dart';

class Flashcard {
  final String id;
  final String groupId;
  final String groupName;
  final String front;
  final String back;
  final int repetitions;
  final double easeFactor;
  final int interval;
  final DateTime nextReview;
  final DateTime createdAt;

  Flashcard({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.front,
    required this.back,
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.interval = 0,
    DateTime? nextReview,
    DateTime? createdAt,
  })  : nextReview = nextReview ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: json['groupId']?.toString() ?? 'default',
      groupName: json['groupName']?.toString() ?? 'Study Set',
      front: json['front']?.toString() ?? '',
      back: json['back']?.toString() ?? '',
      repetitions: json['repetitions'] as int? ?? 0,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      interval: json['interval'] as int? ?? 0,
      nextReview: _parseDate(json['nextReview']),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'groupId': groupId,
    'groupName': groupName,
    'front': front,
    'back': back,
    'repetitions': repetitions,
    'easeFactor': easeFactor,
    'interval': interval,
    'nextReview': nextReview.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  Flashcard copyWith({
    int? repetitions,
    double? easeFactor,
    int? interval,
    DateTime? nextReview,
    String? groupName,
  }) {
    return Flashcard(
      id: id,
      groupId: groupId,
      groupName: groupName ?? this.groupName,
      front: front,
      back: back,
      repetitions: repetitions ?? this.repetitions,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      nextReview: nextReview ?? this.nextReview,
      createdAt: createdAt,
    );
  }
}
