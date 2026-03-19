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

  // stores the notification that launched the app (if any)
  RemoteMessage? _initialMessage;

  @override
  void initState() {
    super.initState();
    UpdateChecker.check();
    // fetch initial notification BEFORE trying to navigate
    // so _resolveAuthenticatedRoute() has the message ready
    _loadInitialMessageThenNavigate();
  }

  // replaces direct _tryNavigate call in initState
  // waits for FCM initial message before deciding where to go
  Future<void> _loadInitialMessageThenNavigate() async {
    _initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    _tryNavigate(ref.read(authProvider));
  }

  void _tryNavigate(AsyncValue<AuthStatus> authState) {
    if (_navigated) return;

    authState.when(
      loading: () {},
      error: (error, _) {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          _navigateToRoute(AppRoutes.login);
          return;
        }
        // use _resolveAuthenticatedRoute() instead of AppRoutes.home
        final route = user.emailVerified
            ? _resolveAuthenticatedRoute()
            : AppRoutes.emailVerify;
        _navigateToRoute(route);
      },
      data: (status) {
        // use _resolveAuthenticatedRoute() instead of AppRoutes.home
        final route = switch (status) {
          AuthStatus.authenticated => _resolveAuthenticatedRoute(),
          AuthStatus.emailNotVerified => AppRoutes.emailVerify,
          AuthStatus.unauthenticated => AppRoutes.login,
        };
        _navigateToRoute(route);
      },
    );
  }

  // decides where to go when user is authenticated
  // checks if app was opened via notification and routes accordingly
  String _resolveAuthenticatedRoute() {
    final message = _initialMessage;

    // no notification — go to home as usual
    if (message == null) return AppRoutes.home;

    final type = message.data['type'] as String?;
    switch (type) {
      case 'new_response':
        // will pass queryId as argument in _navigateToRoute
        return AppRoutes.responses;
      case 'new_query':
        // skip if it's own query
        final posterUid = message.data['posterUid'];
        final currentUid = FirebaseAuth.instance.currentUser?.uid;
        if (posterUid == currentUid) return AppRoutes.home;
        return AppRoutes.home;
      default:
        return AppRoutes.home;
    }
  }

  void _navigateToRoute(String route) {
    if (_navigated) return;
    _navigated = true;

    // pass queryId as argument when navigating to responses screen
    final args = route == AppRoutes.responses
        ? _initialMessage?.data['queryId']
        : null;

    Navigator.of(context).pushReplacementNamed(route, arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    // _tryNavigate now safe to call from listener too
    // because _initialMessage is already loaded before auth resolves
    ref.listen(authProvider, (_, next) => _tryNavigate(next));

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
