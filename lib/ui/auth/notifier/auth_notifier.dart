import 'package:air_query/core/constants/business_constants.dart';
import 'package:air_query/ui/auth/notifier/auth_status.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../repositories/auth/auth_repository.dart';
import '../../../services/fcm_service.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthStatus>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<AuthStatus> {
  late final AuthRepository _authRepository;

  @override
  Future<AuthStatus> build() async {
    _authRepository = AuthRepository();

    final user = _authRepository.currentUser;
    if (user == null) return AuthStatus.unauthenticated;

    // Verified: skip network call entirely, Firebase handles token refresh automatically
    if (user.emailVerified) return AuthStatus.authenticated;

    // Unverified: check if they verified since last session
    try {
      await user.reload();
    } on FirebaseException catch (e) {
      throw e.message ?? 'An error occurred, please try again!';
    }

    final refreshedUser = _authRepository.currentUser;
    if (refreshedUser == null) return AuthStatus.unauthenticated;

    if (refreshedUser.emailVerified) {
      await refreshedUser.getIdToken(
        true,
      ); // force refresh JWT for cloud functions
      return AuthStatus.authenticated;
    }

    return AuthStatus.emailNotVerified;
  }

  Future<void> login({required String id, required String password}) async {
    state = const AsyncLoading();

    try {
      final user = await _authRepository.login(
        email: "$id${BusinessConstants.auEmailDomainExtension}",
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
        FcmService().init();
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

  Future<void> register({required String id, required String password}) async {
    state = const AsyncLoading();

    try {
      final user = await _authRepository.register(
        email: "$id${BusinessConstants.auEmailDomainExtension}",
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

  Future<void> sendPasswordReset(String id) async {
    state = const AsyncLoading();

    try {
      await _authRepository.sendPasswordResetEmail(
        email: "$id${BusinessConstants.auEmailDomainExtension}",
      );
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
        await user.getIdToken(
          true,
        ); // force refresh the JWT (to get verify email status in request to cloud functions)
        state = const AsyncData(AuthStatus.authenticated);
        FcmService().init();
      } else {
        state = const AsyncData(AuthStatus.emailNotVerified);
      }
    } on FirebaseException catch (e) {
      state = AsyncError(
        e.message ?? 'Verification check failed, please try again!',
        StackTrace.current,
      );
    } catch (e) {
      state = AsyncError(
        'Verification check failed, please try again!',
        StackTrace.current,
      );
    }
  }

  Future<void> resendVerificationEmail() async {
    state = const AsyncLoading();

    try {
      final user = await _authRepository.reloadAndGetUser();

      if (user == null) {
        state = const AsyncData(AuthStatus.unauthenticated);
        return;
      }

      // If already verified, no need to resend
      if (user.emailVerified) {
        FcmService().init();
        state = const AsyncData(AuthStatus.authenticated);
        return;
      }

      await _authRepository.sendEmailVerification();
      state = const AsyncData(AuthStatus.emailNotVerified);
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

  // logout
  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await FcmService().deleteToken();
      _authRepository.signOut();
      state = const AsyncData(AuthStatus.unauthenticated);
    } on FirebaseException catch (e) {
      state = AsyncError(
        e.message ?? 'Sign out failed , please try again!',
        StackTrace.current,
      );
    } catch (e) {
      state = AsyncError(
        'Sign out failed, please try again!',
        StackTrace.current,
      );
    }
  }

  Future<void> deleteAccount() async {
    state = const AsyncLoading();
    try {
      await FcmService().deleteToken();
      await _authRepository.deleteAccount();
      state = const AsyncData(AuthStatus.unauthenticated);
    } on FirebaseException catch (e) {
      state = AsyncError(
        e.message ?? 'Account deletion failed, please try again!',
        StackTrace.current,
      );
    } catch (e) {
      state = AsyncError(
        'Account deletion failed, please try again!',
        StackTrace.current,
      );
    }
  }
}
