import 'package:air_query/ui/auth/login_screen.dart';
import 'package:flutter/material.dart';

class AirQuery extends StatelessWidget {
  const AirQuery({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Air Query",
      home: LoginScreen(),
    );
  }
}
