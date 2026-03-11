import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/queries/queries_repository.dart';
import '../../../core/constants/business_constants.dart';
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

  String _errorMessage(Object e) => e is FirebaseFunctionsException
      ? e.message ?? 'Something went wrong.'
      : 'Something went wrong.';
}
