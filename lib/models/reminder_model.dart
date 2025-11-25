// lib/models/reminder_model.dart
import 'dart:convert';

class Reminder {
  final String id;
  final String title;
  final DateTime dateTime;
  String? description;
  bool isCompleted;
  bool isScheduled;
  bool isAuto;

  Reminder({
    required this.id,
    required this.title,
    required this.dateTime,
    this.description,
    this.isCompleted = false,
    this.isScheduled = false,
    this.isAuto = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'dateTime': dateTime.toIso8601String(),
    'description': description,
    'isCompleted': isCompleted,
    'isScheduled': isScheduled,
    'isAuto': isAuto,
  };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
    id: json['id'] as String,
    title: json['title'] as String,
    dateTime: DateTime.parse(json['dateTime'] as String),
    description: json['description'] as String?,
    isCompleted: json['isCompleted'] as bool? ?? false,
    isScheduled: json['isScheduled'] as bool? ?? false,
    isAuto: json['isAuto'] as bool? ?? false,
  );

  String toJsonString() => jsonEncode(toJson());
}
