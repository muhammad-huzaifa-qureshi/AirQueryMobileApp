import 'package:air_query/data/auth/auth_repository.dart';
import 'package:air_query/ui/auth/bloc/auth_event.dart';
import 'package:air_query/ui/auth/bloc/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    // on app starts
    on<AppStarted>((event, emit) async {
      final user = _authRepository.currentUser;
      print(user);

      if (user == null) {
        emit(AuthUnauthenticated());
        return;
      }

      try {
        await user.reload(); // refresh the local user data
      } on FirebaseException catch (e) {
        emit(AuthError(e.message ?? "An error occurred, please try again!"));
        return; // stop further checks
      }

      if (!user.emailVerified) {
        emit(AuthEmailNotVerified());
      } else {
        emit(AuthAuthenticated());
      }
    });

    // Login
    on<LoginRequested>((event, emit) async {
      emit(const AuthLoading());

      try {
        final user = await _authRepository.login(
          email: event.email,
          password: event.password,
        );

        if (user == null) {
          emit(const AuthUnauthenticated());
          return;
        }

        if (!user.emailVerified) {
          // Send verification email
          try {
            await _authRepository.sendEmailVerification();
          } on FirebaseException catch (e) {
            emit(
              AuthError(
                e.message ??
                    "An error occurred while sending email, please try again!",
              ),
            );
            return; // stop, don't emit AuthEmailNotVerified yet
          }

          emit(AuthEmailNotVerified());
        } else {
          emit(AuthAuthenticated());
        }
      } catch (e) {
        emit(
          AuthError(
            e is FirebaseAuthException
                ? e.message ?? "Login failed, please try again!"
                : "Login failed, please try again!",
          ),
        );
      }
    });

    // Register
    on<RegisterRequested>((event, emit) async {
      emit(const AuthLoading());

      try {
        final user = await _authRepository.register(
          email: event.email,
          password: event.password,
        );

        if (user == null) {
          emit(const AuthUnauthenticated());
          return;
        }

        // Send verification email
        try {
          await _authRepository.sendEmailVerification();
        } on FirebaseException catch (e) {
          emit(
            AuthError(
              e.message ??
                  "An error occurred while sending email, please try again!",
            ),
          );
          return; // stop, don't emit AuthEmailNotVerified yet
        }

        emit(AuthEmailNotVerified());
      } catch (e) {
        emit(
          AuthError(
            e is FirebaseAuthException
                ? e.message ?? "Registration failed, please try again!"
                : "Registration failed, please try again!",
          ),
        );
      }
    });
  }
}
