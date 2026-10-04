import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/task_model.dart';
import '../models/priority_enum.dart';
import '../utils/constants.dart';

/// Service responsible for Cloud Firestore task data operations with strict user scoping.
/// Features automatic demo mode fallback for web preview deployments.
class FirestoreService {
  final FirebaseFirestore? _firestore;

  // Mock task storage for demo/offline preview mode
  static final List<TaskModel> _mockTasks = [
    TaskModel(
      id: 'demo-task-1',
      userId: 'demo_user_1',
      title: 'Complete Flutter Capstone Project 🎯',
      description: 'Implement Firebase Auth, Firestore CRUD, Notifications, and Theming.',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      priority: TaskPriority.high,
      isCompleted: false,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      reminderSet: true,
    ),
    TaskModel(
      id: 'demo-task-2',
      userId: 'demo_user_1',
      title: 'Explore Material 3 Theme Modes 🎨',
      description: 'Switch between Light Mode and Dark Mode in the Settings screen.',
      dueDate: DateTime.now().subtract(const Duration(hours: 3)),
      priority: TaskPriority.medium,
      isCompleted: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      reminderSet: false,
    ),
    TaskModel(
      id: 'demo-task-3',
      userId: 'demo_user_1',
      title: 'Filter & Search Tasks 🔍',
      description: 'Filter by pending/completed status or priority, and search by title in real-time.',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      priority: TaskPriority.low,
      isCompleted: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      reminderSet: false,
    ),
    TaskModel(
      id: 'demo-task-4',
      userId: 'demo_user_1',
      title: 'Test Live Android & Web Deployment 🚀',
      description: 'Verify live deployment on GitHub Pages and Android APK builds.',
      dueDate: DateTime.now().add(const Duration(hours: 6)),
      priority: TaskPriority.high,
      isCompleted: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      reminderSet: true,
    ),
  ];

  static final StreamController<List<TaskModel>> _mockStreamController =
      StreamController<List<TaskModel>>.broadcast();

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = (firestore != null)
            ? firestore
            : (Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null);

  /// Whether real Firestore backend is connected.
  bool get isFirebaseAvailable => _firestore != null;

  /// Reference to a user's task subcollection.
  CollectionReference<Map<String, dynamic>> _userTasksRef(String userId) {
    return _firestore!
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.tasksCollection);
  }

  /// Real-time stream of user tasks.
  Stream<List<TaskModel>> getTasksStream(
    String userId, {
    bool? isCompleted,
    String sortBy = 'createdAt',
    bool descending = true,
  }) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    if (isFirebaseAvailable) {
      Query<Map<String, dynamic>> query = _userTasksRef(userId);

      if (isCompleted != null) {
        query = query.where('isCompleted', isEqualTo: isCompleted);
      }

      query = query.orderBy(sortBy, descending: descending);

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
      });
    }

    // Demo/offline mode stream
    return Stream<List<TaskModel>>.multi((controller) {
      // Emit current snapshot immediately
      controller.add(_getFilteredMockTasks(isCompleted, sortBy, descending));

      // Listen for future modifications
      final sub = _mockStreamController.stream.listen((_) {
        controller.add(_getFilteredMockTasks(isCompleted, sortBy, descending));
      });

      controller.onCancel = () => sub.cancel();
    });
  }

  List<TaskModel> _getFilteredMockTasks(
    bool? isCompleted,
    String sortBy,
    bool descending,
  ) {
    var list = List<TaskModel>.from(_mockTasks);
    if (isCompleted != null) {
      list = list.where((t) => t.isCompleted == isCompleted).toList();
    }
    list.sort((a, b) {
      int cmp = a.createdAt.compareTo(b.createdAt);
      return descending ? -cmp : cmp;
    });
    return list;
  }

  /// Create a new task in Cloud Firestore (or local mock store).
  Future<String> createTask(TaskModel task) async {
    if (isFirebaseAvailable) {
      try {
        final docRef = _userTasksRef(task.userId).doc();
        final taskWithId = task.copyWith(
          id: docRef.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await docRef.set(taskWithId.toMap());
        return docRef.id;
      } on FirebaseException catch (e) {
        throw 'Failed to create task: ${e.message}';
      } catch (e) {
        throw 'An unexpected error occurred while saving the task.';
      }
    }

    // Demo Mode Create
    await Future.delayed(const Duration(milliseconds: 150));
    final newId = 'task_${DateTime.now().millisecondsSinceEpoch}';
    final newTask = task.copyWith(
      id: newId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _mockTasks.insert(0, newTask);
    _mockStreamController.add(List.from(_mockTasks));
    return newId;
  }

  /// Update an existing task.
  Future<void> updateTask(TaskModel task) async {
    if (isFirebaseAvailable) {
      try {
        final taskWithUpdatedTimestamp = task.copyWith(
          updatedAt: DateTime.now(),
        );

        await _userTasksRef(task.userId)
            .doc(task.id)
            .update(taskWithUpdatedTimestamp.toMap());
      } on FirebaseException catch (e) {
        throw 'Failed to update task: ${e.message}';
      } catch (e) {
        throw 'An unexpected error occurred while updating the task.';
      }
      return;
    }

    // Demo Mode Update
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _mockTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _mockTasks[index] = task.copyWith(updatedAt: DateTime.now());
      _mockStreamController.add(List.from(_mockTasks));
    }
  }

  /// Toggle task completion status directly.
  Future<void> toggleTaskStatus({
    required String userId,
    required String taskId,
    required bool isCompleted,
  }) async {
    if (isFirebaseAvailable) {
      try {
        await _userTasksRef(userId).doc(taskId).update({
          'isCompleted': isCompleted,
          'updatedAt': Timestamp.now(),
        });
      } on FirebaseException catch (e) {
        throw 'Failed to update status: ${e.message}';
      } catch (e) {
        throw 'An unexpected error occurred while updating task status.';
      }
      return;
    }

    // Demo Mode Toggle
    final index = _mockTasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _mockTasks[index] = _mockTasks[index].copyWith(
        isCompleted: isCompleted,
        updatedAt: DateTime.now(),
      );
      _mockStreamController.add(List.from(_mockTasks));
    }
  }

  /// Delete a task.
  Future<void> deleteTask({
    required String userId,
    required String taskId,
  }) async {
    if (isFirebaseAvailable) {
      try {
        await _userTasksRef(userId).doc(taskId).delete();
      } on FirebaseException catch (e) {
        throw 'Failed to delete task: ${e.message}';
      } catch (e) {
        throw 'An unexpected error occurred while deleting the task.';
      }
      return;
    }

    // Demo Mode Delete
    _mockTasks.removeWhere((t) => t.id == taskId);
    _mockStreamController.add(List.from(_mockTasks));
  }

  /// Fetch a single task by ID.
  Future<TaskModel?> getTaskById({
    required String userId,
    required String taskId,
  }) async {
    if (isFirebaseAvailable) {
      try {
        final doc = await _userTasksRef(userId).doc(taskId).get();
        if (!doc.exists) return null;
        return TaskModel.fromFirestore(doc);
      } catch (e) {
        throw 'Could not retrieve task details.';
      }
    }

    try {
      return _mockTasks.firstWhere((t) => t.id == taskId);
    } catch (_) {
      return null;
    }
  }
}
