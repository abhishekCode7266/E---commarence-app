import 'package:flutter/material.dart';

/// Summary card displaying progress bar and count metrics for tasks.
class TaskStatsCard extends StatelessWidget {
  final int total;
  final int completed;
  final int pending;
  final int overdue;

  const TaskStatsCard({
    super.key,
    required this.total,
    required this.completed,
    required this.pending,
    required this.overdue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double completionRate = total > 0 ? (completed / total) : 0.0;
    final int percentage = (completionRate * 100).toInt();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Task Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$percentage% Done',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: completionRate,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', total.toString(), Icons.list_alt_rounded),
              _buildDivider(),
              _buildStatItem(
                  'Pending', pending.toString(), Icons.pending_actions_rounded),
              _buildDivider(),
              _buildStatItem('Completed', completed.toString(),
                  Icons.task_alt_rounded),
              if (overdue > 0) ...[
                _buildDivider(),
                _buildStatItem('Overdue', overdue.toString(),
                    Icons.error_outline_rounded,
                    highlight: true),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon,
      {bool highlight = false}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: highlight ? const Color(0xFFFFB4AB) : Colors.white70,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: highlight ? const Color(0xFFFFB4AB) : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: highlight ? const Color(0xFFFFB4AB) : Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.white.withOpacity(0.2),
    );
  }
}
