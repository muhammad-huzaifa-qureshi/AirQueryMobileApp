import 'package:air_query/core/routing/app_routes.dart';
import 'package:air_query/ui/auth/notifier/auth_notifier.dart';
import 'package:air_query/ui/auth/notifier/auth_status.dart';
import 'package:air_query/ui/splash/update_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    UpdateChecker.check();
    _tryNavigate(ref.read(authProvider));
  }

  void _tryNavigate(AsyncValue<AuthStatus> authState) {
    if (_navigated) return;

    authState.when(
      loading: () {},
      error: (error, _) {
        // user.reload() failed (e.g. no network).
        // Fall back to cached local session
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          _navigateToRoute(AppRoutes.login);
          return;
        }

        // user exists locally — trust cached emailVerified flag
        final route = user.emailVerified
            ? AppRoutes.home
            : AppRoutes.emailVerify;

        _navigateToRoute(route);
      },
      data: (status) {
        final route = switch (status) {
          AuthStatus.authenticated => AppRoutes.home,
          AuthStatus.emailNotVerified => AppRoutes.emailVerify,
          AuthStatus.unauthenticated => AppRoutes.login,
        };
        _navigateToRoute(route);
      },
    );
  }

  void _navigateToRoute(String route) {
    if (_navigated) return;
    _navigated = true;
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (_, next) => _tryNavigate(next));

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
