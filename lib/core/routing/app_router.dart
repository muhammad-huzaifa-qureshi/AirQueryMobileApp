import 'package:air_query/core/routing/app_routes.dart';
import 'package:air_query/ui/about/about_screen.dart';
import 'package:air_query/ui/app_stats/platform_stats_screen.dart';
import 'package:air_query/ui/auth/forgot_password_screen.dart';
import 'package:air_query/ui/auth/login_screen.dart';
import 'package:air_query/ui/auth/register_screen.dart';
import 'package:air_query/ui/auth/verify_email_screen.dart';
import 'package:air_query/ui/edit_profile/edit_profile_screen.dart';
import 'package:air_query/ui/main/main_screen.dart';
import 'package:air_query/ui/my_queries/my_queries_screen.dart';
import 'package:air_query/ui/post_query/post_query_screen.dart';
import 'package:air_query/ui/profile/profile_screen.dart';
import 'package:air_query/ui/responses/responses_screen.dart';
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
    AppRoutes.home: (_) => const MainScreen(),

    // about
    AppRoutes.about: (_) => const AboutScreen(),
    AppRoutes.platformStats: (_) => const PlatformStatsScreen(),

    // profile
    AppRoutes.profile: (_) => const ProfileScreen(),
    AppRoutes.editProfile: (_) => const EditProfileScreen(),
    AppRoutes.myQueries: (_) => const MyQueriesScreen(),

    // post
    AppRoutes.postQuery: (_) => const PostQueryScreen(),

    // Responses
    AppRoutes.responses: (context) {
      final queryId = ModalRoute.of(context)!.settings.arguments as String;
      return ResponsesScreen(queryId: queryId,);
    },
  };
}
