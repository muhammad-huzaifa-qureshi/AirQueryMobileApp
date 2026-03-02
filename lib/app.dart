import 'package:air_query/core/routing/app_router.dart';
import 'package:air_query/core/routing/app_routes.dart';
import 'package:air_query/core/theme/custom_app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AirQuery extends ConsumerWidget {
  const AirQuery({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Air Query",
      routes: AppRouter.routes,
      theme: CustomAppTheme.darkTheme,
      initialRoute: AppRoutes.home,
    );
  }
}
