import 'package:air_query/core/routing/app_routes.dart';
import 'package:air_query/ui/auth/notifier/auth_notifier.dart';
import 'package:air_query/ui/auth/notifier/auth_status.dart';
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
    _tryNavigate(ref.read(authProvider));
  }

  void _tryNavigate(AsyncValue<AuthStatus> authState) {
    if (_navigated) return;

    authState.when(
      loading: () {},
      error: (_, _) {
        _navigated = true;
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      },
      data: (status) {
        _navigated = true;
        final route = switch (status) {
          AuthStatus.authenticated => AppRoutes.home,
          AuthStatus.emailNotVerified => AppRoutes.emailVerify,
          AuthStatus.unauthenticated => AppRoutes.login,
        };
        Navigator.of(context).pushReplacementNamed(route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (_, next) => _tryNavigate(next));

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}