import 'package:air_query/core/routing/app_routes.dart';
import 'package:air_query/ui/auth/login_screen.dart';
import 'package:air_query/ui/auth/register_screen.dart';
import 'package:air_query/ui/auth/verify_email_screen.dart';
import 'package:air_query/ui/auth/forgot_password_screen.dart';
import 'package:air_query/ui/home/home_screen.dart';
import 'package:air_query/ui/splash/splash_screen.dart';
import 'package:flutter/cupertino.dart';

class AppRouter {
  static Map<String, WidgetBuilder> routes = {
    AppRoutes.splash: (_) => const SplashScreen(),
    AppRoutes.login: (_) => const LoginScreen(),
    AppRoutes.register: (_) => const RegisterScreen(),
    AppRoutes.emailVerify: (_) => const VerifyEmailScreen(),
    AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),

    // home
    AppRoutes.home: (_) => const HomeScreen()
  };
}
