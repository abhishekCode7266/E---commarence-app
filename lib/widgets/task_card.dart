import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../utils/date_formatter.dart';
import 'priority_badge.dart';

/// Interactive task list item card with completion toggle and swipe-to-delete.
class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color dueDateColor = theme.textTheme.bodySmall?.color ?? Colors.grey;
    if (task.isOverdue) {
      dueDateColor = Colors.redAccent;
    } else if (task.isDueToday) {
      dueDateColor = Colors.orangeAccent;
    }

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Task'),
            content: Text('Are you sure you want to delete "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: task.priority.color,
                  width: 5,
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 14, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Checkbox
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 10),
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: task.isCompleted,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      onChanged: onToggle,
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: task.isCompleted
                              ? (isDark ? Colors.grey.shade500 : Colors.grey.shade400)
                              : null,
                        ),
                      ),

                      // Description snippet
                      if (task.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Bottom Metadata Row
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          PriorityBadge(priority: task.priority),

                          if (task.dueDate != null) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  task.isOverdue
                                      ? Icons.warning_amber_rounded
                                      : Icons.access_time_rounded,
                                  size: 13,
                                  color: dueDateColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormatter.formatDueDate(task.dueDate),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: dueDateColor,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          if (task.reminderSet) ...[
                            const Icon(
                              Icons.notifications_active_outlined,
                              size: 14,
                              color: Color(0xFF4F46E5),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
