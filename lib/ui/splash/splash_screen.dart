import 'package:air_query/core/routing/app_routes.dart';
import 'package:air_query/ui/auth/notifier/auth_notifier.dart';
import 'package:air_query/ui/auth/notifier/auth_status.dart';
import 'package:air_query/services/update_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;
  bool _initialMessageLoaded = false; // guards against race condition
  RemoteMessage? _initialMessage;

  @override
  void initState() {
    super.initState();
    UpdateChecker.check();
    _loadInitialMessageThenNavigate();
  }

  Future<void> _loadInitialMessageThenNavigate() async {
    _initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    _initialMessageLoaded = true; // mark as ready before navigating
    _tryNavigate(ref.read(authProvider));
  }

  void _tryNavigate(AsyncValue<AuthStatus> authState) {
    if (_navigated) return;
    if (!_initialMessageLoaded) return; // wait for FCM before navigating

    authState.when(
      loading: () {},
      error: (error, _) {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          _navigateToRoute(AppRoutes.login);
          return;
        }
        final route = user.emailVerified
            ? _resolveAuthenticatedRoute()
            : AppRoutes.emailVerify;
        _navigateToRoute(route);
      },
      data: (status) {
        final route = switch (status) {
          AuthStatus.authenticated => _resolveAuthenticatedRoute(),
          AuthStatus.emailNotVerified => AppRoutes.emailVerify,
          AuthStatus.unauthenticated => AppRoutes.login,
        };
        _navigateToRoute(route);
      },
    );
  }

  String _resolveAuthenticatedRoute() {
    final message = _initialMessage;
    if (message == null) return AppRoutes.home;

    final type = message.data['type'] as String?;
    switch (type) {
      case 'new_response':
        return AppRoutes.responses;
      case 'new_query':
        return AppRoutes.home;
      default:
        return AppRoutes.home;
    }
  }

  void _navigateToRoute(String route) {
    if (_navigated) return;
    _navigated = true;

    final args = route == AppRoutes.responses
        ? _initialMessage?.data['queryId']
        : null;

    Navigator.of(context).pushReplacementNamed(route, arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (_, next) => _tryNavigate(next));
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}