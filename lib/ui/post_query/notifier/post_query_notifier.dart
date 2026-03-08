import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/queries/queries_repository.dart';
import 'post_query_state.dart';

final postQueryProvider =
    NotifierProvider.autoDispose<PostQueryNotifier, PostQueryState>(
      PostQueryNotifier.new,
    );

class PostQueryNotifier extends Notifier<PostQueryState> {
  late final QueriesRepository _repository;

  @override
  PostQueryState build() {
    _repository = QueriesRepository();
    return const PostQueryState();
  }

  Future<void> postQuery({
    required String description,
    required bool postToAllCampuses,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.postQuery(
        description: description,
        postToAllCampuses: postToAllCampuses,
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
