import 'package:air_query/data/auth/auth_repository.dart';
import 'package:air_query/ui/auth/bloc/auth_bloc.dart';
import 'package:air_query/ui/auth/bloc/auth_event.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    BlocProvider(
      create: (_) => AuthBloc(AuthRepository())..add(const AppStarted()),
      child: const AirQuery(),
    ),
  );
}
