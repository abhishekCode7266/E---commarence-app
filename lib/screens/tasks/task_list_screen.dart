import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/priority_enum.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_card.dart';
import '../../widgets/task_filter_bar.dart';
import '../../widgets/task_stats_card.dart';
import '../../widgets/empty_state_view.dart';
import '../settings/settings_screen.dart';
import 'add_edit_task_screen.dart';
import 'task_detail_screen.dart';

/// Main dashboard screen displaying real-time tasks with filtering, search, and sorting.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearchOpen
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _searchController.clear();
                      taskProvider.setSearchQuery('');
                      setState(() {
                        _isSearchOpen = false;
                      });
                    },
                  ),
                ),
                onChanged: (val) => taskProvider.setSearchQuery(val),
              )
            : const Text('My Tasks'),
        actions: [
          if (!_isSearchOpen)
            IconButton(
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Search tasks',
              onPressed: () {
                setState(() {
                  _isSearchOpen = true;
                });
              },
            ),

          // Priority Filter Popup Menu
          PopupMenuButton<TaskPriority?>(
            icon: Icon(
              taskProvider.currentPriorityFilter != null
                  ? Icons.filter_alt_rounded
                  : Icons.filter_alt_outlined,
              color: taskProvider.currentPriorityFilter != null
                  ? theme.colorScheme.primary
                  : null,
            ),
            tooltip: 'Filter by priority',
            onSelected: (priority) {
              taskProvider.setPriorityFilter(priority);
            },
            itemBuilder: (context) => [
              const PopupMenuItem<TaskPriority?>(
                value: null,
                child: Text('All Priorities'),
              ),
              const PopupMenuDivider(),
              ...TaskPriority.values.map(
                (priority) => PopupMenuItem<TaskPriority?>(
                  value: priority,
                  child: Row(
                    children: [
                      Icon(priority.icon, size: 16, color: priority.color),
                      const SizedBox(width: 8),
                      Text(priority.label),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sort Menu
          PopupMenuButton<TaskSortOption>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort tasks',
            onSelected: (option) {
              if (taskProvider.currentSortBy == option) {
                taskProvider.toggleSortOrder();
              } else {
                taskProvider.setSortOption(option);
              }
            },
            itemBuilder: (context) => [
              _buildSortItem('Due Date', TaskSortOption.dueDate, taskProvider),
              _buildSortItem('Priority', TaskSortOption.priority, taskProvider),
              _buildSortItem('Date Created', TaskSortOption.createdAt, taskProvider),
              _buildSortItem('Alphabetical', TaskSortOption.title, taskProvider),
            ],
          ),

          // Settings Button
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Firestore streams automatically update, but we refresh local triggers
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: Column(
          children: [
            // Overview Progress & Metric Card
            TaskStatsCard(
              total: taskProvider.totalCount,
              completed: taskProvider.completedCount,
              pending: taskProvider.pendingCount,
              overdue: taskProvider.overdueCount,
            ),

            // Tab Filter Bar (All / Pending / Completed)
            TaskFilterBar(
              currentFilter: taskProvider.currentFilter,
              totalCount: taskProvider.totalCount,
              pendingCount: taskProvider.pendingCount,
              completedCount: taskProvider.completedCount,
              onFilterSelected: (filter) => taskProvider.setFilter(filter),
            ),

            // Task List or Empty / Loading State
            Expanded(
              child: _buildTaskListBody(context, taskProvider),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddEditTaskScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildTaskListBody(BuildContext context, TaskProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                'Failed to load tasks',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final tasks = provider.filteredTasks;

    if (tasks.isEmpty) {
      if (provider.searchQuery.isNotEmpty ||
          provider.currentPriorityFilter != null) {
        return const EmptyStateView(
          icon: Icons.search_off_rounded,
          title: 'No Matching Tasks',
          message: 'Try adjusting your search query or active priority filter.',
        );
      }

      if (provider.currentFilter == TaskFilter.completed) {
        return const EmptyStateView(
          icon: Icons.assignment_turned_in_outlined,
          title: 'No Completed Tasks',
          message: 'Complete pending tasks to see them highlighted here.',
        );
      }

      return EmptyStateView(
        icon: Icons.task_alt_rounded,
        title: 'No Tasks Yet',
        message: 'Stay productive by adding your first task today.',
        buttonText: 'Create Task',
        onButtonPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddEditTaskScreen(),
            ),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TaskDetailScreen(taskId: task.id),
              ),
            );
          },
          onToggle: (_) {
            provider.toggleTaskStatus(task);
          },
          onDelete: () {
            provider.deleteTask(task);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Deleted "${task.title}"'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    provider.createTask(task);
                  },
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }

  PopupMenuItem<TaskSortOption> _buildSortItem(
    String title,
    TaskSortOption option,
    TaskProvider provider,
  ) {
    final isSelected = provider.currentSortBy == option;
    return PopupMenuItem<TaskSortOption>(
      value: option,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          if (isSelected)
            Icon(
              provider.sortAscending
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 16,
            ),
        ],
      ),
    );
  }
}
