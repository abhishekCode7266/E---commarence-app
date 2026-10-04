import 'package:cloud_firestore/cloud_firestore.dart';
import 'priority_enum.dart';

/// Represents a single user task entity.
class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool reminderSet;

  const TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.reminderSet = false,
  });

  /// Check if the task is overdue (past due date and incomplete).
  bool get isOverdue {
    if (isCompleted || dueDate == null) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  /// Check if the task is due today.
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  /// Create a copy with modified fields.
  TaskModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? reminderSet,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reminderSet: reminderSet ?? this.reminderSet,
    );
  }

  /// Convert TaskModel to Map for Cloud Firestore persistence.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'priority': priority.name,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'reminderSet': reminderSet,
    };
  }

  /// Factory constructor to parse Firestore document snapshot.
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TaskModel.fromMap(data, doc.id);
  }

  /// Factory constructor to parse raw map (supports unit tests & Firestore).
  factory TaskModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic value, DateTime fallback) {
      if (value == null) return fallback;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) {
        return DateTime.tryParse(value) ?? fallback;
      }
      return fallback;
    }

    DateTime? parseNullableDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    final now = DateTime.now();

    return TaskModel(
      id: docId.isNotEmpty ? docId : (map['id'] as String? ?? ''),
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      dueDate: parseNullableDate(map['dueDate']),
      priority: TaskPriority.fromString(map['priority'] as String?),
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: parseDate(map['createdAt'], now),
      updatedAt: parseDate(map['updatedAt'], now),
      reminderSet: map['reminderSet'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.description == description &&
        other.dueDate == dueDate &&
        other.priority == priority &&
        other.isCompleted == isCompleted &&
        other.reminderSet == reminderSet;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      title,
      description,
      dueDate,
      priority,
      isCompleted,
      reminderSet,
    );
  }
}
