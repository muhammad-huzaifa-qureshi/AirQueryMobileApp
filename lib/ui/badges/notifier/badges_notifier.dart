import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../repositories/premium_plan/premium_plan_prices_repository.dart';
import 'badges_state.dart';

final badgesProvider = NotifierProvider.autoDispose<BadgesNotifier, BadgesState>(
  BadgesNotifier.new,
);

class BadgesNotifier extends Notifier<BadgesState> {
  late final PremiumPlanPricesRepository _repository;

  @override
  BadgesState build() {
    _repository = PremiumPlanPricesRepository();
    Future.microtask(fetchPremiumPlanPricing);
    return const BadgesState(isLoading: true);
  }

  Future<void> fetchPremiumPlanPricing() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final pricing = await _repository.fetchPremiumPlanPricing();
      state = state.copyWith(pricing: pricing, isLoading: false);
    } catch (e) {
      final message = e is FirebaseException
          ? e.message ?? 'Something went wrong.'
          : 'Something went wrong.';
      state = state.copyWith(isLoading: false, error: message);
    }
  }
}
