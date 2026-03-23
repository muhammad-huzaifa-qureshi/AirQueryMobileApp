import 'package:air_query/repositories/auth/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/business_constants.dart';
import '../../../repositories/responses/responses_repository.dart';
import 'responses_state.dart';

final responsesProvider = NotifierProvider.autoDispose
    .family<ResponsesNotifier, ResponsesState, String>(ResponsesNotifier.new);

class ResponsesNotifier extends Notifier<ResponsesState> {
  // family argument
  ResponsesNotifier(this._queryId);

  final String _queryId;
  late final String? currentUserID;
  late final ResponsesRepository _repository;

  @override
  ResponsesState build() {
    _repository = ResponsesRepository();
    currentUserID = AuthRepository().currentUser?.uid;

    Future.microtask(fetchInitial);
    return const ResponsesState();
  }

  Future<void> fetchInitial() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final responses = await _repository.fetchResponses(queryId: _queryId);
      state = state.copyWith(
        responses: responses,
        isLoading: false,
        hasMore: responses.length == BusinessConstants.queryFetchLimit,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _errorMessage(e));
    }
  }

  Future<void> fetchMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final lastId = state.responses.isNotEmpty
          ? state.responses.last.id
          : null;

      final more = await _repository.fetchResponses(
        queryId: _queryId,
        startAfterId: lastId,
      );

      state = state.copyWith(
        responses: [...state.responses, ...more],
        isLoadingMore: false,
        hasMore: more.length == BusinessConstants.queryFetchLimit,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: _errorMessage(e));
    }
  }

  Future<void> refresh() async {
    state = const ResponsesState(isLoading: true);

    try {
      final responses = await _repository.fetchResponses(queryId: _queryId);

      state = ResponsesState(
        responses: responses,
        hasMore: responses.length == BusinessConstants.queryFetchLimit,
      );
    } catch (e) {
      state = ResponsesState(error: _errorMessage(e));
    }
  }

  Future<void> postResponse(String description) async {
    try {
      await _repository.postResponse(
        queryId: _queryId,
        description: description,
      );

      await refresh();
    } catch (e) {
      state = state.copyWith(error: _errorMessage(e));
    }
  }

  Future<void> deleteResponse(String responseId) async {
    try {
      await _repository.deleteResponse(
        queryId: _queryId,
        responseId: responseId,
      );

      state = state.copyWith(
        responses: state.responses.where((r) => r.id != responseId).toList(),
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(error: _errorMessage(e));
    }
  }

  String _errorMessage(Object e) {
    if (e is FirebaseException) {
      return e.message ?? 'Something went wrong.';
    }
    return 'Something went wrong.';
  }
}
