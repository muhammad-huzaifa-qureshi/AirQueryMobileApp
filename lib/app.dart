import 'package:air_query/core/routing/app_router.dart';
import 'package:air_query/core/routing/app_routes.dart';
import 'package:air_query/core/theme/custom_app_theme.dart';
import 'package:air_query/ui/auth/bloc/auth_bloc.dart';
import 'package:air_query/ui/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AirQuery extends StatelessWidget {
  const AirQuery({super.key});

  @override
  Widget build(BuildContext context) {
    // todo: issue here
    final authState = context.read<AuthBloc>().state;

    String initialScreen;

    if (authState is AuthInitial || authState is AuthLoading) {
      initialScreen = AppRoutes.splash;
    } else if (authState is AuthAuthenticated) {
      initialScreen = AppRoutes.home;
    } else if (authState is AuthUnauthenticated) {
      print("here");
      initialScreen = AppRoutes.login;
      print("here2");
    } else if (authState is AuthEmailNotVerified) {
      initialScreen = AppRoutes.emailVerify;
    } else {
      initialScreen = AppRoutes.login;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Air Query",
      routes: AppRouter.routes,
      theme: CustomAppTheme.darkTheme,
      initialRoute: initialScreen,
    );
  }
}
