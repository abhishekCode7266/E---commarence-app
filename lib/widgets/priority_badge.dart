import 'package:flutter/material.dart';
import '../models/priority_enum.dart';

/// Clean pill badge indicating priority level.
class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final bool showIcon;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = priority.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(priority.icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            priority.label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
