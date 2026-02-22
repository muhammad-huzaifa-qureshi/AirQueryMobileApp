import 'package:air_query/ui/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';

void main() {
  runApp(
    BlocProvider(
      create: (_) => AuthBloc(),
      child: const AirQuery(),
    )
  );
}
