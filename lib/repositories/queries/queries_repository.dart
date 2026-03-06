import 'package:cloud_functions/cloud_functions.dart';
import '../../models/query_model.dart';

class QueriesRepository {
  final _functions = FirebaseFunctions.instanceFor(region: "asia-south1");

  Future<List<QueryModel>> fetchQueries({String? startAfterId}) async {
    final callable = _functions.httpsCallable('getQueries');
    final result = await callable.call({'startAfter': startAfterId});

    final data = result.data['queries'] as List;
    return data.map((q) {
      final map = Map<String, dynamic>.from(q as Map);
      return QueryModel.fromMap(map, map['id']);
    }).toList();
  }
}
