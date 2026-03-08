class PostQueryState {
  final bool isLoading;
  final bool success;
  final String? error;

  const PostQueryState({
    this.isLoading = false,
    this.success = false,
    this.error,
  });

  PostQueryState copyWith({
    bool? isLoading,
    bool? success,
    String? error,
    bool clearError = false,
  }) {
    return PostQueryState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
