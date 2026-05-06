import '../../../models/query_model.dart';

class HomeQueriesState {
  final List<QueryModel> queries;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final String? minorActionsSuccess; // for report, delete, resolve, etc.

  const HomeQueriesState({
    this.queries = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.minorActionsSuccess,
  });

  HomeQueriesState copyWith({
    List<QueryModel>? queries,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    String? minorActionsSuccess,
    bool clearError = false,
    bool clearMinorActionsSuccess = false,
  }) {
    return HomeQueriesState(
      queries: queries ?? this.queries,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      minorActionsSuccess: clearMinorActionsSuccess
          ? null
          : (minorActionsSuccess ?? this.minorActionsSuccess),
    );
  }
}
