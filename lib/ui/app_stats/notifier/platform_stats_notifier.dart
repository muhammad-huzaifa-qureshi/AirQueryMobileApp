import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/stats/platform_stats_repository.dart';
import 'platform_stats_state.dart';

final platformStatsProvider =
    NotifierProvider.autoDispose<PlatformStatsNotifier, PlatformStatsState>(
      PlatformStatsNotifier.new,
    );

class PlatformStatsNotifier extends Notifier<PlatformStatsState> {
  late final PlatformStatsRepository _repository;

  @override
  PlatformStatsState build() {
    _repository = PlatformStatsRepository();
    Future.microtask(fetchStats);
    return const PlatformStatsState(isLoading: true);
  }

  Future<void> fetchStats() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final stats = await _repository.fetchPlatformStats();
      state = state.copyWith(stats: stats, isLoading: false);
    } catch (e) {
      final message = e is FirebaseFunctionsException
          ? e.message ?? 'Something went wrong.'
          : 'Something went wrong.';
      state = state.copyWith(isLoading: false, error: message);
    }
  }
}
