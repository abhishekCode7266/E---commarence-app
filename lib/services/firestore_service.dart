import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../utils/constants.dart';

/// Service responsible for Cloud Firestore task data operations with strict user scoping.
class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Reference to a user's task subcollection.
  CollectionReference<Map<String, dynamic>> _userTasksRef(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.tasksCollection);
  }

  /// Real-time stream of user tasks.
  /// Supports optional filtering by completion status and custom sorting.
  Stream<List<TaskModel>> getTasksStream(
    String userId, {
    bool? isCompleted,
    String sortBy = 'createdAt',
    bool descending = true,
  }) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    Query<Map<String, dynamic>> query = _userTasksRef(userId);

    // Apply completion filter if provided
    if (isCompleted != null) {
      query = query.where('isCompleted', isEqualTo: isCompleted);
    }

    // Apply sorting
    query = query.orderBy(sortBy, descending: descending);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    });
  }

  /// Create a new task in Cloud Firestore.
  Future<String> createTask(TaskModel task) async {
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

  /// Update an existing task in Cloud Firestore.
  Future<void> updateTask(TaskModel task) async {
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
  }

  /// Toggle task completion status directly.
  Future<void> toggleTaskStatus({
    required String userId,
    required String taskId,
    required bool isCompleted,
  }) async {
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
  }

  /// Delete a task from Cloud Firestore.
  Future<void> deleteTask({
    required String userId,
    required String taskId,
  }) async {
    try {
      await _userTasksRef(userId).doc(taskId).delete();
    } on FirebaseException catch (e) {
      throw 'Failed to delete task: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred while deleting the task.';
    }
  }

  /// Fetch a single task by ID.
  Future<TaskModel?> getTaskById({
    required String userId,
    required String taskId,
  }) async {
    try {
      final doc = await _userTasksRef(userId).doc(taskId).get();
      if (!doc.exists) return null;
      return TaskModel.fromFirestore(doc);
    } catch (e) {
      throw 'Could not retrieve task details.';
    }
  }
}
