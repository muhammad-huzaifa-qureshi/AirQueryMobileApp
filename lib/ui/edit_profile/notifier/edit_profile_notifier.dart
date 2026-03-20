import 'package:air_query/services/fcm_service.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/user/user_repository.dart';
import 'edit_profile_state.dart';

final editProfileProvider =
    NotifierProvider.autoDispose<EditProfileNotifier, EditProfileState>(
      EditProfileNotifier.new,
    );

class EditProfileNotifier extends Notifier<EditProfileState> {
  late final UserRepository _repository;

  @override
  EditProfileState build() {
    _repository = UserRepository();
    return const EditProfileState();
  }

  Future<void> updateProfile({
    required String name,
    required String campus,
    required String semester,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.updateProfile(
        name: name,
        campus: campus,
        semester: semester,
      );
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      final message = e is FirebaseFunctionsException
          ? e.message ?? 'Something went wrong.'
          : 'Something went wrong.';
      state = state.copyWith(isLoading: false, error: message);
    }
  }
}
