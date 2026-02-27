import 'package:air_query/data/auth/auth_repository.dart';
import 'package:flutter/cupertino.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AuthRepository().signOut();
    return const Text("home");
  }
}
