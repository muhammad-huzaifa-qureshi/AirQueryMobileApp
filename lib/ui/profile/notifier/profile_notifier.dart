import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../repositories/user/user_repository.dart';
import 'profile_state.dart';

final profileProvider =
    NotifierProvider.autoDispose<ProfileNotifier, ProfileState>(
      ProfileNotifier.new,
    );

class ProfileNotifier extends Notifier<ProfileState> {
  late final UserRepository _repository;

  @override
  ProfileState build() {
    _repository = UserRepository();
    Future.microtask(fetchProfile);
    return const ProfileState(isLoading: true);
  }

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.fetchProfile();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      final message = e is FirebaseException
          ? e.message ?? 'Something went wrong.'
          : 'Something went wrong.';
      state = state.copyWith(isLoading: false, error: message);
    }
  }
}
