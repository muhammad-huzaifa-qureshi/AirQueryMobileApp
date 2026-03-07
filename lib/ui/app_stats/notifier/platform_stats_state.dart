import '../../../models/platform_stats_model.dart';

class PlatformStatsState {
  final PlatformStatsModel? stats;
  final bool isLoading;
  final String? error;

  const PlatformStatsState({this.stats, this.isLoading = false, this.error});

  PlatformStatsState copyWith({
    PlatformStatsModel? stats,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return PlatformStatsState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
