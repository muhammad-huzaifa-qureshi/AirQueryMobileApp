import 'package:cloud_functions/cloud_functions.dart';
import '../../models/response_model.dart';

class ResponsesRepository {
  final _functions = FirebaseFunctions.instanceFor(region: "asia-south1");

  Future<List<ResponseModel>> fetchResponses({
    required String queryId,
    String? startAfterId,
  }) async {
    final callable = _functions.httpsCallable('getResponses');
    final result = await callable.call({
      'queryId': queryId,
      'startAfter': startAfterId,
    });

    final data = result.data['responses'] as List;
    return data.map((r) {
      final map = Map<String, dynamic>.from(r as Map);
      return ResponseModel.fromMap(map, map['id']);
    }).toList();
  }

  Future<void> postResponse({
    required String queryId,
    required String description,
  }) async {
    final callable = _functions.httpsCallable('postResponse');
    await callable.call({'queryId': queryId, 'description': description});
  }

  Future<void> deleteResponse({
    required String queryId,
    required String responseId,
  }) async {
    final callable = _functions.httpsCallable('deleteResponse');
    await callable.call({'queryId': queryId, 'responseId': responseId});
  }
}
