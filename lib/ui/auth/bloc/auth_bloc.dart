import 'package:air_query/data/auth/auth_repository.dart';
import 'package:air_query/ui/auth/bloc/auth_event.dart';
import 'package:air_query/ui/auth/bloc/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    // TODO: on app started
    on<AppStarted>((event, emit) {
      emit(const AuthUnauthenticated());
    });
    // Login
    on<LoginRequested>((event, emit) async {
      emit(const AuthLoading());

      try {
        final user = await _authRepository.login(
          email: event.email,
          password: event.password,
        );
        if (user != null) {
          emit(AuthAuthenticated());
        } else {
          emit(const AuthUnauthenticated());
        }
      } catch (e) {
        // Catch FirebaseAuthException or general errors
        emit(
          AuthError(
            e is FirebaseAuthException
                ? e.message ?? "Login failed, please try again!"
                : "Login failed, please try again!",
          ),
        );
      }
    });
  }
}
