import 'package:cloud_functions/cloud_functions.dart';
import '../../models/platform_stats_model.dart';

class PlatformStatsRepository {
  final _functions = FirebaseFunctions.instanceFor(region: 'asia-south1');

  Future<PlatformStatsModel> fetchPlatformStats() async {
    final callable = _functions.httpsCallable('getPlatformStats');
    final result = await callable.call();

    final data = Map<String, dynamic>.from(result.data as Map);
    return PlatformStatsModel.fromMap(data);
  }
}
