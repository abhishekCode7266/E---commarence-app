import 'package:flutter/material.dart';

/// Represents priority levels for tasks.
enum TaskPriority {
  low,
  medium,
  high;

  /// Human-readable label for UI display.
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  /// Accent color associated with priority level.
  Color get color {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFF4CAF50); // Green
      case TaskPriority.medium:
        return const Color(0xFFFF9800); // Orange
      case TaskPriority.high:
        return const Color(0xFFF44336); // Red
    }
  }

  /// Material icon representing priority level.
  IconData get icon {
    switch (this) {
      case TaskPriority.low:
        return Icons.arrow_downward_rounded;
      case TaskPriority.medium:
        return Icons.remove_rounded;
      case TaskPriority.high:
        return Icons.arrow_upward_rounded;
    }
  }

  /// Parse string from Firestore safely into enum.
  static TaskPriority fromString(String? value) {
    if (value == null) return TaskPriority.medium;
    switch (value.toLowerCase()) {
      case 'low':
        return TaskPriority.low;
      case 'high':
        return TaskPriority.high;
      case 'medium':
      default:
        return TaskPriority.medium;
    }
  }
}
