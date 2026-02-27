import 'package:air_query/data/auth/auth_repository.dart';
import 'package:air_query/ui/auth/notifier/auth_status.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthStatus>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AuthStatus> {
  late final AuthRepository _authRepository;

  @override
  Future<AuthStatus> build() async {
    _authRepository = ref.read(authRepositoryProvider);

    final user = _authRepository.currentUser;

    if (user == null) return AuthStatus.unauthenticated;

    try {
      await user.reload();
    } on FirebaseException catch (e) {
      throw e.message ?? 'An error occurred, please try again!';
    }

    return user.emailVerified
        ? AuthStatus.authenticated
        : AuthStatus.emailNotVerified;
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );

      if (user == null) {
        state = const AsyncData(AuthStatus.unauthenticated);
        return;
      }

      if (!user.emailVerified) {
        try {
          await _authRepository.sendEmailVerification();
        } on FirebaseException catch (e) {
          state = AsyncError(
            e.message ??
                'An error occurred while sending email, please try again!',
            StackTrace.current,
          );
          return;
        }

        state = const AsyncData(AuthStatus.emailNotVerified);
      } else {
        state = const AsyncData(AuthStatus.authenticated);
      }
    } catch (e) {
      state = AsyncError(
        e is FirebaseAuthException
            ? e.message ?? 'Login failed, please try again!'
            : 'Login failed, please try again!',
        StackTrace.current,
      );
    }
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final user = await _authRepository.register(
        email: email,
        password: password,
      );

      if (user == null) {
        state = const AsyncData(AuthStatus.unauthenticated);
        return;
      }

      try {
        await _authRepository.sendEmailVerification();
      } on FirebaseException catch (e) {
        state = AsyncError(
          e.message ??
              'An error occurred while sending email, please try again!',
          StackTrace.current,
        );
        return;
      }

      state = const AsyncData(AuthStatus.emailNotVerified);
    } catch (e) {
      state = AsyncError(
        e is FirebaseAuthException
            ? e.message ?? 'Registration failed, please try again!'
            : 'Registration failed, please try again!',
        StackTrace.current,
      );
    }
  }

  Future<void> sendPasswordReset(String email) async {
    state = const AsyncLoading();

    try {
      await _authRepository.sendPasswordResetEmail(email: email);
      state = AsyncData(state.value ?? AuthStatus.unauthenticated);
    } on FirebaseException catch (e) {
      state = AsyncError(
        e.message ?? 'Failed to send reset email, please try again!',
        StackTrace.current,
      );
    } catch (e) {
      state = AsyncError(
        'Failed to send reset email, please try again!',
        StackTrace.current,
      );
    }
  }

  Future<void> checkEmailVerification() async {
    state = const AsyncLoading();

    try {
      final user = await _authRepository.reloadAndGetUser();

      if (user == null) {
        state = const AsyncData(AuthStatus.unauthenticated);
        return;
      }

      if (user.emailVerified) {
        state = const AsyncData(AuthStatus.authenticated);
      } else {
        state = AsyncError(
          'Email not verified yet. Please check your inbox and spam folder.',
          StackTrace.current,
        );
      }
    } on FirebaseException catch (e) {
      state = AsyncError(
        e.message ?? 'Verification check failed, please try again!',
        StackTrace.current,
      );
    }
  }

  Future<void> resendVerificationEmail() async {
    state = const AsyncLoading();

    try {
      await _authRepository.sendEmailVerification();
      state = AsyncData(state.value ?? AuthStatus.emailNotVerified);
    } on FirebaseException catch (e) {
      state = AsyncError(
        e.message ?? 'Failed to resend email, please try again!',
        StackTrace.current,
      );
    } catch (e) {
      state = AsyncError(
        'Failed to resend email, please try again!',
        StackTrace.current,
      );
    }
  }
}
