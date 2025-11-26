import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notification_provider.dart';
import '../models/notification.dart' as app_notification;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              final unreadCount = notificationProvider.unreadCount;
              if (unreadCount > 0) {
                return TextButton(
                  onPressed: () async {
                    await notificationProvider.markAllAsRead();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All notifications marked as read')),
                    );
                  },
                  child: const Text(
                    'Mark All Read',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
              switch (value) {
                case 'clear_all':
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear All Notifications'),
                      content: const Text('Are you sure you want to delete all notifications?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await notificationProvider.clearAllNotifications();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All notifications cleared')),
                      );
                    }
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Text('Clear All'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = notificationProvider.notifications;

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return NotificationTile(
                notification: notification,
                onMarkAsRead: () async {
                  await notificationProvider.markAsRead(notification.id);
                },
                onDelete: () async {
                  await notificationProvider.deleteNotification(notification.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notification deleted')),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final app_notification.Notification notification;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onMarkAsRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) => onDelete(),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNotificationColor(notification.type),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  _formatTimestamp(notification.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                _buildPriorityChip(notification.priority),
                const SizedBox(width: 8),
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: !notification.isRead
            ? IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: onMarkAsRead,
                tooltip: 'Mark as read',
              )
            : null,
        onTap: !notification.isRead ? onMarkAsRead : null,
        tileColor: notification.isRead ? null : Colors.blue[50],
      ),
    );
  }

  Color _getNotificationColor(app_notification.NotificationType type) {
    switch (type) {
      case app_notification.NotificationType.task:
        return Colors.red;
      case app_notification.NotificationType.announcement:
        return Colors.blue;
      case app_notification.NotificationType.liveClass:
        return Colors.green;
      case app_notification.NotificationType.aiReminder:
        return Colors.purple;
    }
  }

  IconData _getNotificationIcon(app_notification.NotificationType type) {
    switch (type) {
      case app_notification.NotificationType.task:
        return Icons.assignment;
      case app_notification.NotificationType.announcement:
        return Icons.announcement;
      case app_notification.NotificationType.liveClass:
        return Icons.video_call;
      case app_notification.NotificationType.aiReminder:
        return Icons.smart_toy;
    }
  }

  Widget _buildPriorityChip(app_notification.NotificationPriority priority) {
    Color color;
    String label;

    switch (priority) {
      case app_notification.NotificationPriority.low:
        color = Colors.grey;
        label = 'Low';
        break;
      case app_notification.NotificationPriority.medium:
        color = Colors.orange;
        label = 'Medium';
        break;
      case app_notification.NotificationPriority.high:
        color = Colors.red;
        label = 'High';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return DateFormat('MMM d, yyyy').format(timestamp);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}