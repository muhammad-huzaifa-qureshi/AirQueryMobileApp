import 'package:air_query/core/routing/app_router.dart';
import 'package:air_query/services/notification_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/custom_app_theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class AirQuery extends StatefulWidget {
  const AirQuery({super.key});

  @override
  State<AirQuery> createState() => _AirQueryState();
}

class _AirQueryState extends State<AirQuery> {
  late final NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService(navigatorKey);
    _notificationService.init();
  }

  @override
  void dispose() {
    _notificationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: "Air Query",
      routes: AppRouter.routes,
      theme: CustomAppTheme.darkTheme,
      initialRoute: AppRoutes.splash,

      // for firebase analytics
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
    );
  }
}
