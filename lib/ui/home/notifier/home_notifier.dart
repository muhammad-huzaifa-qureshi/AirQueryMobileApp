import 'package:air_query/core/constants/business_constants.dart';
import 'package:air_query/repositories/auth/auth_repository.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/queries/queries_repository.dart';
import 'home_query_state.dart';

// Provider
final homeProvider = NotifierProvider<HomeNotifier, HomeQueriesState>(
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
        hasMore: queries.length == BusinessConstants.queryFetchLimit
      );
    } catch (e) {
      final message = e is FirebaseFunctionsException
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
      final message = e is FirebaseFunctionsException
          ? e.message ?? 'Something went wrong.'
          : 'Something went wrong.';
      state = state.copyWith(isLoadingMore: false, error: message);
    }
  }

  Future<void> refresh() async {
    state = const HomeQueriesState(isLoading: true);
    try {
      final queries = await _repository.fetchQueries();
      state = HomeQueriesState(queries: queries, hasMore: queries.length == BusinessConstants.queryFetchLimit);
    } catch (e) {
      final message = e is FirebaseFunctionsException
          ? e.message ?? 'Something went wrong.'
          : 'Something went wrong.';
      state = HomeQueriesState(error: message);
    }
  }
}
