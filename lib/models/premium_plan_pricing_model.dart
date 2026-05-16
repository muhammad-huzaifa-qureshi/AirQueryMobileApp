class PremiumPlanPricingModel {
  final double? premiumActualPricePKR;
  final double? premiumDiscountedPricePKR;

  PremiumPlanPricingModel({
    this.premiumActualPricePKR,
    this.premiumDiscountedPricePKR,
  });

  factory PremiumPlanPricingModel.fromMap(Map<String, dynamic> map) {
    return PremiumPlanPricingModel(
      premiumActualPricePKR: map['premiumActualPricePKR'] != null
          ? double.tryParse(map['premiumActualPricePKR'].toString())
          : null,
      premiumDiscountedPricePKR: map['premiumDiscountedPricePKR'] != null
          ? double.tryParse(map['premiumDiscountedPricePKR'].toString())
          : null,
    );
  }
}
