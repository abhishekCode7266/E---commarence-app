import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../utils/constants.dart';

/// Top-level background message handler for FCM.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM Background message: ${message.messageId}');
}

/// Service managing local scheduled task reminders and Firebase Cloud Messaging.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin? _localNotifications =
      kIsWeb ? null : FlutterLocalNotificationsPlugin();

  FirebaseMessaging? _fcmInstance;
  FirebaseMessaging get _fcm => _fcmInstance ??= FirebaseMessaging.instance;

  bool _initialized = false;

  /// Initialize notification settings, timezones, and FCM handlers.
  Future<void> initialize({Function(String?)? onNotificationTap}) async {
    if (_initialized) return;

    if (!kIsWeb && _localNotifications != null) {
      // Initialize time zone database for exact reminders on mobile
      try {
        tz.initializeTimeZones();
      } catch (e) {
        debugPrint('Timezone initialization note: $e');
      }

      // Android initialization settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Darwin (iOS/macOS) initialization settings
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (onNotificationTap != null && response.payload != null) {
            onNotificationTap(response.payload);
          }
        },
      );

      // Create high-importance Android Notification Channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        description: AppConstants.notificationChannelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(channel);
      }
    }

    // Configure FCM safely
    try {
      await _configureFCM();
    } catch (e) {
      debugPrint('FCM configuration note: $e');
    }

    _initialized = true;
  }

  /// Request permissions for local and push notifications.
  Future<bool> requestPermissions() async {
    if (kIsWeb) {
      try {
        final settings = await _fcm.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        return settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
      } catch (e) {
        return false;
      }
    }

    bool localGranted = false;

    if (defaultTargetPlatform == TargetPlatform.android &&
        _localNotifications != null) {
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      localGranted =
          await androidImplementation?.requestNotificationsPermission() ??
              false;
    } else if (defaultTargetPlatform == TargetPlatform.iOS &&
        _localNotifications != null) {
      final iosImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      localGranted =
          await iosImplementation?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      return localGranted &&
          (settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional);
    } catch (e) {
      return localGranted;
    }
  }

  /// Configure Firebase Cloud Messaging event listeners.
  Future<void> _configureFCM() async {
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }

    // Foreground notification listener
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
  }

  /// Get device FCM registration token.
  Future<String?> getFCMToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Show an immediate local notification.
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb || _localNotifications == null) return;

    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  /// Schedule a notification for a task at a specific due date and time.
  Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (kIsWeb || _localNotifications == null) return;
    if (scheduledDate.isBefore(DateTime.now())) return;

    final tz.TZDateTime tzScheduledDate =
        tz.TZDateTime.from(scheduledDate, tz.local);

    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error scheduling task reminder: $e');
    }
  }

  /// Cancel a scheduled task reminder by its ID.
  Future<void> cancelReminder(int id) async {
    if (kIsWeb || _localNotifications == null) return;
    await _localNotifications.cancel(id);
  }

  /// Cancel all pending notifications.
  Future<void> cancelAll() async {
    if (kIsWeb || _localNotifications == null) return;
    await _localNotifications.cancelAll();
  }
}
