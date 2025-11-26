import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/notification.dart' as app_notification;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for iOS
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to specific screen
    print('Notification tapped: ${response.payload}');
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'smart_classroom_channel',
      'Smart Classroom Notifications',
      channelDescription: 'Notifications for Smart Classroom app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'smart_classroom_channel',
      'Smart Classroom Notifications',
      channelDescription: 'Notifications for Smart Classroom app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Helper methods for specific notification types
  Future<void> scheduleTaskDeadlineNotification({
    required String taskTitle,
    required DateTime deadline,
    required String userId,
  }) async {
    final notificationTime = deadline.subtract(const Duration(hours: 1));
    if (notificationTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: taskTitle.hashCode,
        title: 'Task Deadline Reminder',
        body: 'Your task "$taskTitle" is due in 1 hour',
        scheduledTime: notificationTime,
        payload: '{"type": "task", "userId": "$userId"}',
      );
    }
  }

  Future<void> scheduleLiveClassReminder({
    required String classTitle,
    required DateTime classTime,
    required String userId,
  }) async {
    final notificationTime = classTime.subtract(const Duration(minutes: 15));
    if (notificationTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: classTitle.hashCode,
        title: 'Live Class Reminder',
        body: 'Your live class "$classTitle" starts in 15 minutes',
        scheduledTime: notificationTime,
        payload: '{"type": "live_class", "userId": "$userId"}',
      );
    }
  }

  Future<void> showAnnouncementNotification({
    required String title,
    required String message,
    required String userId,
  }) async {
    await showInstantNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: message,
      payload: '{"type": "announcement", "userId": "$userId"}',
    );
  }

  Future<void> showAiReminderNotification({
    required String title,
    required String message,
    required String userId,
  }) async {
    await showInstantNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: message,
      payload: '{"type": "ai_reminder", "userId": "$userId"}',
    );
  }

  // Settings management
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  Future<Map<String, bool>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'task': prefs.getBool('notification_task') ?? true,
      'announcement': prefs.getBool('notification_announcement') ?? true,
      'live_class': prefs.getBool('notification_live_class') ?? true,
      'ai_reminder': prefs.getBool('notification_ai_reminder') ?? true,
    };
  }

  Future<void> setNotificationSettings(Map<String, bool> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_task', settings['task'] ?? true);
    await prefs.setBool('notification_announcement', settings['announcement'] ?? true);
    await prefs.setBool('notification_live_class', settings['live_class'] ?? true);
    await prefs.setBool('notification_ai_reminder', settings['ai_reminder'] ?? true);
  }

  Future<bool> shouldShowNotification(app_notification.NotificationType type) async {
    if (!(await areNotificationsEnabled())) return false;

    final settings = await getNotificationSettings();
    switch (type) {
      case app_notification.NotificationType.task:
        return settings['task'] ?? true;
      case app_notification.NotificationType.announcement:
        return settings['announcement'] ?? true;
      case app_notification.NotificationType.liveClass:
        return settings['live_class'] ?? true;
      case app_notification.NotificationType.aiReminder:
        return settings['ai_reminder'] ?? true;
    }
  }
}