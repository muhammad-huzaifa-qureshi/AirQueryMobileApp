import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/business_constants.dart';
import '../../../repositories/queries/queries_repository.dart';
import 'my_queries_state.dart';

final myQueriesProvider =
    NotifierProvider.autoDispose<MyQueriesNotifier, MyQueriesState>(
      MyQueriesNotifier.new,
    );

class MyQueriesNotifier extends Notifier<MyQueriesState> {
  late final QueriesRepository _repository;

  @override
  MyQueriesState build() {
    _repository = QueriesRepository();
    Future.microtask(fetchInitial);
    return const MyQueriesState();
  }

  Future<void> fetchInitial() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final queries = await _repository.fetchMyQueries();
      state = state.copyWith(
        queries: queries,
        isLoading: false,
        hasMore: queries.length == BusinessConstants.queryFetchLimit,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _errorMessage(e));
    }
  }

  Future<void> fetchMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final lastId = state.queries.isNotEmpty ? state.queries.last.id : null;
      final more = await _repository.fetchMyQueries(startAfterId: lastId);
      state = state.copyWith(
        queries: [...state.queries, ...more],
        isLoadingMore: false,
        hasMore: more.length == BusinessConstants.queryFetchLimit,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: _errorMessage(e));
    }
  }

  Future<void> refresh() async {
    state = const MyQueriesState(isLoading: true);
    try {
      final queries = await _repository.fetchMyQueries();
      state = MyQueriesState(
        queries: queries,
        hasMore: queries.length == BusinessConstants.queryFetchLimit,
      );
    } catch (e) {
      state = MyQueriesState(error: _errorMessage(e));
    }
  }

  Future<void> deleteQuery(String queryId) async {
    try {
      await _repository.deleteQuery(queryId: queryId);
      state = state.copyWith(
        queries: state.queries.where((q) => q.id != queryId).toList(),
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(error: _errorMessage(e));
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
      );
    } catch (e) {
      state = state.copyWith(error: _errorMessage(e));
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

  String _errorMessage(Object e) => e is FirebaseException
      ? e.message ?? 'Something went wrong.'
      : 'Something went wrong.';
}
