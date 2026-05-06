import 'package:air_query/core/constants/business_constants.dart';
import 'package:air_query/models/query_model.dart';
import 'package:air_query/repositories/auth/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/queries/queries_repository.dart';
import 'home_query_state.dart';

// Provider
final homeProvider =
    NotifierProvider.autoDispose<HomeNotifier, HomeQueriesState>(
      HomeNotifier.new,
    );

class HomeNotifier extends Notifier<HomeQueriesState> {
  late final QueriesRepository _repository;
  late final String? currentUserID;

  @override
  HomeQueriesState build() {
    _repository = QueriesRepository();
    currentUserID = AuthRepository().currentUser?.uid;

    // schedule after build completes
    Future.microtask(fetchInitial);

    return const HomeQueriesState();
  }

  Future<void> fetchInitial() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final queries = await _repository.fetchQueries();
      state = state.copyWith(
        queries: queries,
        isLoading: false,
        hasMore: queries.length == BusinessConstants.queryFetchLimit,
      );
    } catch (e) {
      final message = e is FirebaseException
          ? e.message ?? 'Something went wrong.'
          : 'Something went wrong.';
      state = state.copyWith(isLoading: false, error: message);
    }
  }

  Future<void> fetchMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final lastId = state.queries.isNotEmpty ? state.queries.last.id : null;
      final more = await _repository.fetchQueries(startAfterId: lastId);
      state = state.copyWith(
        queries: [...state.queries, ...more],
        isLoadingMore: false,
        hasMore: more.length == BusinessConstants.queryFetchLimit,
      );
    } catch (e) {
      final message = e is FirebaseException
          ? e.message ?? 'Something went wrong.'
          : 'Something went wrong.';
      state = state.copyWith(isLoadingMore: false, error: message);
    }
  }

  Future<void> refresh() async {
    state = const HomeQueriesState(isLoading: true);
    try {
      final queries = await _repository.fetchQueries();
      state = HomeQueriesState(
        queries: queries,
        hasMore: queries.length == BusinessConstants.queryFetchLimit,
      );
    } catch (e) {
      final message = e is FirebaseException
          ? e.message ?? 'Something went wrong.'
          : 'Something went wrong.';
      state = HomeQueriesState(error: message);
    }
  }

  Future<void> deleteQuery(String queryId) async {
    try {
      await _repository.deleteQuery(queryId: queryId);
      state = state.copyWith(
        queries: state.queries.where((q) => q.id != queryId).toList(),
        clearError: true,
        minorActionsSuccess: 'Query deleted!',
      );
      await Future.microtask(
        () => state = state.copyWith(clearMinorActionsSuccess: true),
      );
    } catch (e) {
      final message = e is FirebaseException
          ? e.message ?? 'Something went wrong.'
          : 'Something went wrong.';
      state = state.copyWith(error: message);
    }
  }

  Future<void> resolveQuery(String queryId) async {
    try {
      await _repository.resolveQuery(queryId: queryId);
      state = state.copyWith(
        queries: state.queries
            .map((q) => q.id == queryId ? q.copyWith(isResolved: true) : q)
            .toList(),
        clearError: true,
        minorActionsSuccess: 'Query Resolved!',
      );
      await Future.microtask(
        () => state = state.copyWith(clearMinorActionsSuccess: true),
      );
    } catch (e) {
      final message = e is FirebaseException
          ? e.message ?? 'Something went wrong.'
          : 'Something went wrong.';
      state = state.copyWith(error: message);
    }
  }

  Future<void> reportQuery(QueryModel query) async {
    try {
      await _repository.reportQuery(query: query);
      state = state.copyWith(
        clearError: true,
        minorActionsSuccess:
            "Thanks for your cooperation, our team will look into this!",
      );
      await Future.microtask(
        () => state = state.copyWith(clearMinorActionsSuccess: true),
      );
    } catch (e) {
      final message = e is FirebaseException
          ? e.message ?? 'Something went wrong.'
          : 'Something went wrong.';
      state = state.copyWith(error: message);
    }
  }

  // for in-memory count update (no db fetch)
  // called when a del/post response done
  void updateResponseCount(String queryId, int delta) {
    state = state.copyWith(
      queries: state.queries
          .map(
            (q) => q.id == queryId
                ? q.copyWith(responseCount: q.responseCount + delta)
                : q,
          )
          .toList(),
    );
  }
}
