import 'dart:async';
import 'package:flutter/material.dart';

enum NotificationType { info, success, warning, error }

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final Duration duration;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.type = NotificationType.info,
    this.duration = const Duration(seconds: 4),
  });
}

class NotificationService with ChangeNotifier {
  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  void showNotification(AppNotification notification) {
    _notifications.add(notification);
    notifyListeners();

    // Auto remove notification after its duration
    Timer(notification.duration, () {
      removeNotificationById(notification.id);
    });
  }

  void removeNotificationById(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}
