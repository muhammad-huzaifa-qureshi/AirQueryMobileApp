import '../../../models/query_model.dart';

class HomeQueriesState {
  final List<QueryModel> queries;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const HomeQueriesState({
    this.queries = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  HomeQueriesState copyWith({
    List<QueryModel>? queries,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return HomeQueriesState(
      queries: queries ?? this.queries,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
