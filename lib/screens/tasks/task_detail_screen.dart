import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/confirm_dialog.dart';
import 'add_edit_task_screen.dart';

/// Screen displaying complete details of a selected task.
class TaskDetailScreen extends StatelessWidget {
  final String taskId;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    // Locate task in provider
    final taskIndex =
        taskProvider.allTasks.indexWhere((element) => element.id == taskId);

    if (taskIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Details')),
        body: const Center(
          child: Text('This task no longer exists or was deleted.'),
        ),
      );
    }

    final task = taskProvider.allTasks[taskIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit task',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditTaskScreen(taskToEdit: task),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            tooltip: 'Delete task',
            onPressed: () async {
              final confirmed = await ConfirmDialog.show(
                context,
                title: 'Delete Task',
                message: 'Are you sure you want to permanently delete this task?',
                confirmText: 'Delete',
                isDestructive: true,
              );

              if (confirmed && context.mounted) {
                await taskProvider.deleteTask(task);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? Colors.green.withOpacity(0.12)
                    : Colors.amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: task.isCompleted
                      ? Colors.green.withOpacity(0.3)
                      : Colors.amber.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        task.isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.pending_actions_rounded,
                        color: task.isCompleted
                            ? Colors.green.shade700
                            : Colors.amber.shade800,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        task.isCompleted ? 'Status: Completed' : 'Status: Pending',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: task.isCompleted
                              ? Colors.green.shade800
                              : Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => taskProvider.toggleTaskStatus(task),
                    child: Text(
                      task.isCompleted ? 'Mark Pending' : 'Mark Complete',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Priority and Due Date Badges
            Row(
              children: [
                PriorityBadge(priority: task.priority),
                const SizedBox(width: 10),
                if (task.isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            size: 13, color: Colors.red),
                        SizedBox(width: 4),
                        Text(
                          'Overdue',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            SelectableText(
              task.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            const SizedBox(height: 16),

            // Description
            const Text(
              'Description',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            SelectableText(
              task.description.trim().isNotEmpty
                  ? task.description
                  : 'No description provided.',
              style: TextStyle(
                fontSize: 15,
                color: task.description.trim().isNotEmpty
                    ? theme.textTheme.bodyMedium?.color
                    : Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            const Divider(),
            const SizedBox(height: 16),

            // Due Date Section
            _buildDetailRow(
              icon: Icons.calendar_today_rounded,
              label: 'Due Date & Time',
              value: DateFormatter.formatDueDate(task.dueDate),
            ),
            const SizedBox(height: 12),

            // Reminder status
            _buildDetailRow(
              icon: task.reminderSet
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
              label: 'Scheduled Reminder',
              value: task.reminderSet
                  ? 'Active notification scheduled'
                  : 'No notification scheduled',
            ),
            const SizedBox(height: 12),

            // Created At
            _buildDetailRow(
              icon: Icons.history_rounded,
              label: 'Created',
              value: DateFormatter.formatFull(task.createdAt),
            ),
            const SizedBox(height: 12),

            // Updated At
            _buildDetailRow(
              icon: Icons.update_rounded,
              label: 'Last Modified',
              value: DateFormatter.formatFull(task.updatedAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
