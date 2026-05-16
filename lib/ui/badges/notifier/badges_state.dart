import '../../../models/premium_plan_pricing_model.dart';

class BadgesState {
  final PremiumPlanPricingModel? pricing;
  final bool isLoading;
  final String? error;

  const BadgesState({this.pricing, this.isLoading = false, this.error});

  BadgesState copyWith({
    PremiumPlanPricingModel? pricing,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return BadgesState(
      pricing: pricing ?? this.pricing,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
