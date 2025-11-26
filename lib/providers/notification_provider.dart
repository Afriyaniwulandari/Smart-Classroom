import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification.dart' as app_notification;
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  List<app_notification.Notification> _notifications = [];
  bool _isLoading = false;

  List<app_notification.Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> initialize() async {
    await _notificationService.initialize();
    await _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList('notifications') ?? [];

      _notifications = notificationsJson
          .map((json) => app_notification.Notification.fromJson(jsonDecode(json)))
          .toList();

      // Sort by timestamp (newest first)
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('Error loading notifications: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = _notifications
          .map((notification) => jsonEncode(notification.toJson()))
          .toList();
      await prefs.setStringList('notifications', notificationsJson);
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }

  Future<void> addNotification(app_notification.Notification notification) async {
    // Check if notifications are enabled for this type
    if (!(await _notificationService.shouldShowNotification(notification.type))) {
      return;
    }

    _notifications.insert(0, notification); // Add to beginning
    await _saveNotifications();
    notifyListeners();

    // Show instant notification if it's not a scheduled one
    if (notification.type != app_notification.NotificationType.task &&
        notification.type != app_notification.NotificationType.liveClass) {
      await _showInstantNotification(notification);
    }
  }

  Future<void> _showInstantNotification(app_notification.Notification notification) async {
    String title = notification.title;
    String body = notification.message;

    switch (notification.type) {
      case app_notification.NotificationType.announcement:
        await _notificationService.showAnnouncementNotification(
          title: title,
          message: body,
          userId: notification.userId,
        );
        break;
      case app_notification.NotificationType.aiReminder:
        await _notificationService.showAiReminderNotification(
          title: title,
          message: body,
          userId: notification.userId,
        );
        break;
      default:
        break;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _saveNotifications();
    notifyListeners();
  }

  // Helper methods for creating specific types of notifications
  Future<void> createTaskDeadlineNotification({
    required String userId,
    required String taskTitle,
    required DateTime deadline,
    String? taskId,
  }) async {
    final notification = app_notification.Notification(
      id: 'task_${taskId ?? DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: app_notification.NotificationType.task,
      priority: app_notification.NotificationPriority.high,
      title: 'Task Deadline Approaching',
      message: 'Your task "$taskTitle" is due on ${deadline.toString().split(' ')[0]}',
      timestamp: DateTime.now(),
      data: {'taskId': taskId, 'deadline': deadline.toIso8601String()},
    );

    await addNotification(notification);

    // Schedule the actual notification
    await _notificationService.scheduleTaskDeadlineNotification(
      taskTitle: taskTitle,
      deadline: deadline,
      userId: userId,
    );
  }

  Future<void> createLiveClassReminder({
    required String userId,
    required String classTitle,
    required DateTime classTime,
    String? classId,
  }) async {
    final notification = app_notification.Notification(
      id: 'live_class_${classId ?? DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: app_notification.NotificationType.liveClass,
      priority: app_notification.NotificationPriority.high,
      title: 'Live Class Reminder',
      message: 'You have a live class "$classTitle" scheduled for ${classTime.toString()}',
      timestamp: DateTime.now(),
      data: {'classId': classId, 'classTime': classTime.toIso8601String()},
    );

    await addNotification(notification);

    // Schedule the actual notification
    await _notificationService.scheduleLiveClassReminder(
      classTitle: classTitle,
      classTime: classTime,
      userId: userId,
    );
  }

  Future<void> createAnnouncement({
    required String userId,
    required String title,
    required String message,
    String? classId,
  }) async {
    final notification = app_notification.Notification(
      id: 'announcement_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: app_notification.NotificationType.announcement,
      priority: app_notification.NotificationPriority.medium,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      data: {'classId': classId},
    );

    await addNotification(notification);
  }

  Future<void> createAiReminder({
    required String userId,
    required String title,
    required String message,
    String? relatedId,
  }) async {
    final notification = app_notification.Notification(
      id: 'ai_reminder_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: app_notification.NotificationType.aiReminder,
      priority: app_notification.NotificationPriority.low,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      data: {'relatedId': relatedId},
    );

    await addNotification(notification);
  }

  // Settings management
  Future<bool> areNotificationsEnabled() async {
    return await _notificationService.areNotificationsEnabled();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _notificationService.setNotificationsEnabled(enabled);
    notifyListeners();
  }

  Future<Map<String, bool>> getNotificationSettings() async {
    return await _notificationService.getNotificationSettings();
  }

  Future<void> setNotificationSettings(Map<String, bool> settings) async {
    await _notificationService.setNotificationSettings(settings);
    notifyListeners();
  }

  // Filter methods
  List<app_notification.Notification> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  List<app_notification.Notification> getNotificationsByType(app_notification.NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  List<app_notification.Notification> getNotificationsByPriority(app_notification.NotificationPriority priority) {
    return _notifications.where((n) => n.priority == priority).toList();
  }
}