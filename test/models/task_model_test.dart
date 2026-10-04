import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_capstone/models/task_model.dart';
import 'package:flutter_todo_capstone/models/priority_enum.dart';

void main() {
  group('TaskModel Unit Tests', () {
    final now = DateTime.now();

    test('should construct TaskModel with correct default values', () {
      final task = TaskModel(
        id: 'task-123',
        userId: 'user-456',
        title: 'Review Project Documentation',
        createdAt: now,
        updatedAt: now,
      );

      expect(task.id, 'task-123');
      expect(task.userId, 'user-456');
      expect(task.title, 'Review Project Documentation');
      expect(task.description, '');
      expect(task.priority, TaskPriority.medium);
      expect(task.isCompleted, false);
      expect(task.reminderSet, false);
      expect(task.dueDate, isNull);
    });

    test('should serialize to Map correctly for Firestore', () {
      final dueDate = DateTime(2026, 12, 31, 18, 0);
      final task = TaskModel(
        id: 'task-100',
        userId: 'user-001',
        title: 'Submit Capstone Deliverables',
        description: 'Prepare video demo and APK',
        dueDate: dueDate,
        priority: TaskPriority.high,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
        reminderSet: true,
      );

      final map = task.toMap();

      expect(map['id'], 'task-100');
      expect(map['userId'], 'user-001');
      expect(map['title'], 'Submit Capstone Deliverables');
      expect(map['description'], 'Prepare video demo and APK');
      expect(map['priority'], 'high');
      expect(map['isCompleted'], false);
      expect(map['reminderSet'], true);
      expect(map['dueDate'], isNotNull);
    });

    test('should deserialize from Map correctly', () {
      final map = {
        'id': 'task-200',
        'userId': 'user-002',
        'title': 'Test Firebase Rules',
        'description': 'Run security rules suite',
        'dueDate': '2026-10-15T10:00:00.000',
        'priority': 'low',
        'isCompleted': true,
        'createdAt': '2026-10-01T08:00:00.000',
        'updatedAt': '2026-10-02T09:00:00.000',
        'reminderSet': false,
      };

      final task = TaskModel.fromMap(map, 'task-200');

      expect(task.id, 'task-200');
      expect(task.userId, 'user-002');
      expect(task.title, 'Test Firebase Rules');
      expect(task.priority, TaskPriority.low);
      expect(task.isCompleted, true);
      expect(task.reminderSet, false);
      expect(task.dueDate, DateTime(2026, 10, 15, 10, 0));
    });

    test('isOverdue should return true only for incomplete past tasks', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 2));
      final futureDate = DateTime.now().add(const Duration(days: 2));

      final overdueTask = TaskModel(
        id: '1',
        userId: 'u1',
        title: 'Past task',
        dueDate: pastDate,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );

      final completedPastTask = TaskModel(
        id: '2',
        userId: 'u1',
        title: 'Past done task',
        dueDate: pastDate,
        isCompleted: true,
        createdAt: now,
        updatedAt: now,
      );

      final futureTask = TaskModel(
        id: '3',
        userId: 'u1',
        title: 'Future task',
        dueDate: futureDate,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );

      expect(overdueTask.isOverdue, isTrue);
      expect(completedPastTask.isOverdue, isFalse);
      expect(futureTask.isOverdue, isFalse);
    });

    test('copyWith creates a new instance with updated properties', () {
      final task = TaskModel(
        id: 'orig-id',
        userId: 'orig-user',
        title: 'Original Title',
        createdAt: now,
        updatedAt: now,
      );

      final updated = task.copyWith(
        title: 'Updated Title',
        isCompleted: true,
        priority: TaskPriority.high,
      );

      expect(updated.id, 'orig-id');
      expect(updated.title, 'Updated Title');
      expect(updated.isCompleted, true);
      expect(updated.priority, TaskPriority.high);
    });
  });
}
