import 'package:intl/intl.dart';

/// Formatter for friendly user-facing dates.
class DateFormatter {
  /// Format task due date concisely (e.g., "Today, 5:00 PM", "Tomorrow", "Oct 15, 2026").
  static String formatDueDate(DateTime? date) {
    if (date == null) return 'No due date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final differenceInDays = targetDate.difference(today).inDays;

    final timeString = DateFormat('h:mm a').format(date);

    if (differenceInDays == 0) {
      return 'Today, $timeString';
    } else if (differenceInDays == 1) {
      return 'Tomorrow, $timeString';
    } else if (differenceInDays == -1) {
      return 'Yesterday, $timeString';
    } else if (date.year == now.year) {
      return DateFormat('MMM d, h:mm a').format(date);
    } else {
      return DateFormat('MMM d, yyyy, h:mm a').format(date);
    }
  }

  /// Format date for task list chips (e.g. "Oct 15").
  static String formatShortDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d').format(date);
  }

  /// Full readable date string.
  static String formatFull(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy • h:mm a').format(date);
  }
}
