class EditProfileState {
  final bool isLoading;
  final bool success;
  final String? error;

  const EditProfileState({
    this.isLoading = false,
    this.success = false,
    this.error,
  });

  EditProfileState copyWith({
    bool? isLoading,
    bool? success,
    String? error,
    bool clearError = false,
  }) {
    return EditProfileState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
