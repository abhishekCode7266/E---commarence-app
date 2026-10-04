import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

/// Web implementation of NotificationService without any dart:io or mobile-only plugins.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _initialized = false;

  /// Initialize notification settings safely on Web.
  Future<void> initialize({Function(String?)? onNotificationTap}) async {
    if (_initialized) return;

    if (Firebase.apps.isNotEmpty) {
      try {
        final fcm = FirebaseMessaging.instance;
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          final notification = message.notification;
          if (notification != null) {
            showImmediateNotification(
              id: message.hashCode,
              title: notification.title ?? 'Task Reminder',
              body: notification.body ?? '',
              payload: message.data['taskId'],
            );
          }
        });
      } catch (e) {
        debugPrint('Web FCM initialization note: $e');
      }
    }

    _initialized = true;
  }

  /// Request permissions for notifications on Web.
  Future<bool> requestPermissions() async {
    if (Firebase.apps.isNotEmpty) {
      try {
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        return settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
      } catch (e) {
        debugPrint('Web notification permission note: $e');
      }
    }
    return true;
  }

  /// Get FCM token on Web.
  Future<String?> getFCMToken() async {
    if (Firebase.apps.isNotEmpty) {
      try {
        return await FirebaseMessaging.instance.getToken();
      } catch (e) {
        debugPrint('Web FCM token note: $e');
      }
    }
    return 'web-demo-fcm-token';
  }

  /// Show an immediate notification on Web.
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    debugPrint('[Web Notification] $title: $body');
  }

  /// Schedule a task reminder on Web.
  Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    debugPrint('[Web Scheduled Reminder] id=$id, date=$scheduledDate, title=$title');
  }

  /// Cancel a scheduled task reminder by its ID.
  Future<void> cancelReminder(int id) async {
    debugPrint('[Web Cancel Reminder] id=$id');
  }

  /// Cancel all pending notifications.
  Future<void> cancelAll() async {
    debugPrint('[Web Cancel All Reminders]');
  }
}
