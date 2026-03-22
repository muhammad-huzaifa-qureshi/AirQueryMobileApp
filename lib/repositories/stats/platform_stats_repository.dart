import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/platform_stats_model.dart';

class PlatformStatsRepository {
  final _firestore = FirebaseFirestore.instance;

  Future<PlatformStatsModel> fetchPlatformStats() async {
    final doc = await _firestore
        .collection("platformStats")
        .doc("global")
        .get();

    if (!doc.exists || doc.data() == null) {
      return PlatformStatsModel(
        totalQueriesPosted: 0,
        totalQueriesResolved: 0,
        totalResponses: 0,
      );
    }

    return PlatformStatsModel.fromMap(doc.data()!);
  }
}
