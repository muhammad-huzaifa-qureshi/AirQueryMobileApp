import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/premium_plan_pricing_model.dart';

class PremiumPlanPricesRepository {
  final _firestore = FirebaseFirestore.instance;

  Future<PremiumPlanPricingModel?> fetchPremiumPlanPricing() async {
    final doc = await _firestore
        .collection("premiumPlanPricing")
        .doc("current")
        .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return PremiumPlanPricingModel.fromMap(doc.data()!);
  }
}
