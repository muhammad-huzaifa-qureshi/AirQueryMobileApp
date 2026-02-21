import 'package:air_query/ui/auth/bloc/auth_event.dart';
import 'package:air_query/ui/auth/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState(count: 0)) {

    on<Increment>((event, emit) {
      emit(state.copyWith(count: state.count + 1));
    });

    on<Decrement>((event, emit) {
      emit(state.copyWith(count: state.count - 1));
    });
  }
}