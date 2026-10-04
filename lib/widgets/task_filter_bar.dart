import 'package:flutter/material.dart';
import '../providers/task_provider.dart';

/// Horizontal tab filter bar for switching between All, Pending, and Completed tasks.
class TaskFilterBar extends StatelessWidget {
  final TaskFilter currentFilter;
  final int totalCount;
  final int pendingCount;
  final int completedCount;
  final ValueChanged<TaskFilter> onFilterSelected;

  const TaskFilterBar({
    super.key,
    required this.currentFilter,
    required this.totalCount,
    required this.pendingCount,
    required this.completedCount,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(
            context,
            filter: TaskFilter.all,
            label: 'All',
            count: totalCount,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            filter: TaskFilter.pending,
            label: 'Pending',
            count: pendingCount,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            filter: TaskFilter.completed,
            label: 'Completed',
            count: completedCount,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required TaskFilter filter,
    required String label,
    required int count,
  }) {
    final theme = Theme.of(context);
    final isSelected = currentFilter == filter;

    return FilterChip(
      selected: isSelected,
      label: Text('$label ($count)'),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected
            ? theme.colorScheme.onPrimary
            : theme.textTheme.bodyMedium?.color,
      ),
      selectedColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      showCheckmark: false,
      onSelected: (_) => onFilterSelected(filter),
    );
  }
}
