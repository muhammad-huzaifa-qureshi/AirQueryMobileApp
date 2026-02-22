import 'package:air_query/ui/auth/bloc/auth_event.dart';
import 'package:air_query/ui/auth/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthInitial()) {
    // TODO: on app started
    on<AppStarted>((event, emit) {
      emit(const AuthUnauthenticated());
    });
    // Login
    on<LoginRequested>((event, emit) async {
      emit(const AuthLoading());
      // TODO: api call
    });
  }
}
