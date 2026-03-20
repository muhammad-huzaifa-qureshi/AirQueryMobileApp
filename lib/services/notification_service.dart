import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../core/routing/app_routes.dart';

class NotificationService {
  final GlobalKey<NavigatorState> _navigatorKey;
  final List<StreamSubscription> _subscriptions = [];

  NotificationService(this._navigatorKey);

  Future<void> init() async {
    // terminated state — handled by SplashScreen

    // Background
    _subscriptions.add(
      FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => _handleTap(message.data),
      ),
    );

    // Foreground
    _subscriptions.add(FirebaseMessaging.onMessage.listen(_handleForeground));
  }

  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  void _handleForeground(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    final context = _navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(notification.body ?? ''),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => _handleTap(message.data),
        ),
      ),
    );
  }

  void _handleTap(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    if (type == null) return;

    switch (type) {
      case 'new_response':
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.responses,
          (route) => false,
          arguments: data['queryId'],
        );
      case 'new_query':
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.home,
          (route) => false,
        );
    }
  }
}
