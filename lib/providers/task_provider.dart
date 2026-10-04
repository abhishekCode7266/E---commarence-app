import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../models/priority_enum.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

enum TaskFilter { all, pending, completed }
enum TaskSortOption { dueDate, priority, createdAt, title }

/// Provider managing task list, filters, real-time Firestore sync, and reminders.
class TaskProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final NotificationService _notificationService;

  StreamSubscription<List<TaskModel>>? _tasksSubscription;
  String? _currentUserId;

  List<TaskModel> _allTasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter & Search states
  TaskFilter _filter = TaskFilter.all;
  TaskPriority? _priorityFilter;
  String _searchQuery = '';
  TaskSortOption _sortBy = TaskSortOption.createdAt;
  bool _sortAscending = false;

  TaskProvider({
    FirestoreService? firestoreService,
    NotificationService? notificationService,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _notificationService = notificationService ?? NotificationService();

  // Getters
  List<TaskModel> get allTasks => _allTasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TaskFilter get currentFilter => _filter;
  TaskPriority? get currentPriorityFilter => _priorityFilter;
  String get searchQuery => _searchQuery;
  TaskSortOption get currentSortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  // Statistics counters
  int get totalCount => _allTasks.length;
  int get completedCount => _allTasks.where((t) => t.isCompleted).length;
  int get pendingCount => _allTasks.where((t) => !t.isCompleted).length;
  int get overdueCount => _allTasks.where((t) => t.isOverdue).length;

  /// Returns tasks filtered and sorted according to user selection.
  List<TaskModel> get filteredTasks {
    List<TaskModel> result = List.from(_allTasks);

    // Filter by completion status
    switch (_filter) {
      case TaskFilter.pending:
        result = result.where((t) => !t.isCompleted).toList();
        break;
      case TaskFilter.completed:
        result = result.where((t) => t.isCompleted).toList();
        break;
      case TaskFilter.all:
        break;
    }

    // Filter by priority
    if (_priorityFilter != null) {
      result = result.where((t) => t.priority == _priorityFilter).toList();
    }

    // Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      result = result.where((t) {
        return t.title.toLowerCase().contains(query) ||
            t.description.toLowerCase().contains(query);
      }).toList();
    }

    // Sort
    result.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case TaskSortOption.dueDate:
          if (a.dueDate == null && b.dueDate == null) {
            comparison = 0;
          } else if (a.dueDate == null) {
            comparison = 1;
          } else if (b.dueDate == null) {
            comparison = -1;
          } else {
            comparison = a.dueDate!.compareTo(b.dueDate!);
          }
          break;
        case TaskSortOption.priority:
          comparison = a.priority.index.compareTo(b.priority.index);
          break;
        case TaskSortOption.title:
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case TaskSortOption.createdAt:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return result;
  }

  /// Attach or switch user and subscribe to their real-time task stream.
  void updateUserId(String? userId) {
    if (_currentUserId == userId) return;

    _currentUserId = userId;
    _tasksSubscription?.cancel();

    if (userId == null || userId.isEmpty) {
      _allTasks = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _tasksSubscription = _firestoreService
        .getTasksStream(userId)
        .listen(
          (tasks) {
            _allTasks = tasks;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = error.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  /// Filter setters
  void setFilter(TaskFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortOption(TaskSortOption sortBy, {bool? ascending}) {
    _sortBy = sortBy;
    if (ascending != null) {
      _sortAscending = ascending;
    }
    notifyListeners();
  }

  void toggleSortOrder() {
    _sortAscending = !_sortAscending;
    notifyListeners();
  }

  /// Task CRUD methods
  Future<bool> createTask(TaskModel task) async {
    try {
      final docId = await _firestoreService.createTask(task);

      // Schedule local notification if reminder enabled and due date is set
      if (task.reminderSet && task.dueDate != null) {
        final reminderId = docId.hashCode;
        await _notificationService.scheduleTaskReminder(
          id: reminderId,
          title: 'Upcoming Task: ${task.title}',
          body: task.description.isNotEmpty
              ? task.description
              : 'This task is due now!',
          scheduledDate: task.dueDate!,
          payload: docId,
        );
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    try {
      await _firestoreService.updateTask(task);

      final reminderId = task.id.hashCode;
      if (task.reminderSet && task.dueDate != null && !task.isCompleted) {
        await _notificationService.scheduleTaskReminder(
          id: reminderId,
          title: 'Upcoming Task: ${task.title}',
          body: task.description.isNotEmpty
              ? task.description
              : 'This task is due now!',
          scheduledDate: task.dueDate!,
          payload: task.id,
        );
      } else {
        await _notificationService.cancelReminder(reminderId);
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleTaskStatus(TaskModel task) async {
    final newStatus = !task.isCompleted;
    try {
      await _firestoreService.toggleTaskStatus(
        userId: task.userId,
        taskId: task.id,
        isCompleted: newStatus,
      );

      // Cancel reminder if marked as completed
      if (newStatus && task.reminderSet) {
        await _notificationService.cancelReminder(task.id.hashCode);
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(TaskModel task) async {
    try {
      await _firestoreService.deleteTask(
        userId: task.userId,
        taskId: task.id,
      );
      // Cancel any pending notifications for this task
      await _notificationService.cancelReminder(task.id.hashCode);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
