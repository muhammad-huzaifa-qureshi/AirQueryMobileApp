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

  Future<void> postQuery({
    required String description,
    required bool postToAllCampuses,
  }) async {
    final callable = _functions.httpsCallable('postQuery');
    await callable.call({
      'description': description,
      'postToAll': postToAllCampuses,
    });
  }

  Future<void> deleteQuery({required String queryId}) async {
    final callable = _functions.httpsCallable('deleteQuery');
    await callable.call({'queryId': queryId});
  }

  Future<void> resolveQuery({required String queryId}) async {
    final callable = _functions.httpsCallable('resolveQuery');
    await callable.call({'queryId': queryId});
  }
}
