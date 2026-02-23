import 'package:air_query/core/routing/app_router.dart';
import 'package:air_query/core/theme/custom_app_theme.dart';
import 'package:air_query/ui/auth/bloc/auth_bloc.dart';
import 'package:air_query/ui/auth/bloc/auth_state.dart';
import 'package:air_query/ui/auth/login_screen.dart';
import 'package:air_query/ui/home/home_screen.dart';
import 'package:air_query/ui/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AirQuery extends StatelessWidget {
  const AirQuery({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Air Query",
      routes: AppRouter.routes,
      theme: CustomAppTheme.darkTheme,

      // start destination decider
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthInitial) {
            return const SplashScreen();
          }
          if (state is AuthAuthenticated) {
            return const HomeScreen();
          }
          if (state is AuthUnauthenticated || state is AuthError) {
            return const LoginScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
