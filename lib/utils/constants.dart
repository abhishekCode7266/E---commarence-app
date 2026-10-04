/// Application-wide constants
class AppConstants {
  static const String appName = 'TaskFlow';
  static const String appTagline = 'Focus. Organize. Achieve.';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String tasksCollection = 'tasks';

  // SharedPreferences Keys
  static const String keyThemeMode = 'app_theme_mode';
  static const String keyNotificationsEnabled = 'notifications_enabled';

  // Notification Channel
  static const String notificationChannelId = 'task_reminders_channel';
  static const String notificationChannelName = 'Task Reminders';
  static const String notificationChannelDescription =
      'Notifications for scheduled task deadlines and reminders';

  // Error Messages
  static const String networkErrorMessage =
      'Network connection unavailable. Please check your internet connection.';
  static const String unknownErrorMessage =
      'An unexpected error occurred. Please try again.';
  static const String unauthorizedMessage =
      'You are not authorized to perform this operation.';
}
