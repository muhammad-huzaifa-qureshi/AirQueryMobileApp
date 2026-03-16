import 'dart:async';

import 'package:air_query/models/user_model.dart';
import 'package:air_query/repositories/user/user_repository.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final otherUserProfileProvider = AsyncNotifierProvider.autoDispose
    .family<OtherUserProfileNotifier, UserModel, String>(
      OtherUserProfileNotifier.new,
    );

class OtherUserProfileNotifier extends AsyncNotifier<UserModel> {
  final String userId;

  OtherUserProfileNotifier(this.userId);

  @override
  Future<UserModel> build() async {
    try {
      return await UserRepository().fetchOtherUserProfile(userId);
    } on FirebaseFunctionsException catch (e) {
      throw e.message ?? 'Failed to load profile.';
    } catch (e) {
      throw 'Failed to load profile.';
    }
  }
}
