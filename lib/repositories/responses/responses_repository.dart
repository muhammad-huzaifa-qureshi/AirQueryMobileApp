import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/business_constants.dart';
import '../../models/response_model.dart';
import '../auth/auth_repository.dart';

class ResponsesRepository {
  final _functions = FirebaseFunctions.instanceFor(region: "asia-south1");
  final _firestore = FirebaseFirestore.instance;

  Future<List<ResponseModel>> fetchResponses({
    required String queryId,
    String? startAfterId,
  }) async {
    final uid = AuthRepository().currentUser?.uid;
    if (uid == null) {
      throw FirebaseAuthException(
        code: 'unauthenticated',
        message: 'Please login to continue',
      );
    }

    Query query = _firestore
        .collection('queries')
        .doc(queryId)
        .collection('responses')
        .orderBy('postedAt', descending: true)
        .limit(BusinessConstants.responseFetchLimit);

    if (startAfterId != null) {
      final cursorDoc = await _firestore
          .collection('queries')
          .doc(queryId)
          .collection('responses')
          .doc(startAfterId)
          .get();

      if (!cursorDoc.exists) return [];

      query = query.startAfterDocument(cursorDoc);
    }

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      return ResponseModel.fromMap(
        Map<String, dynamic>.from(doc.data() as Map),
        doc.id,
      );
    }).toList();
  }

  Future<void> postResponse({
    required String queryId,
    required String description,
    String? mentionedUid,
    String? mentionedName
  }) async {
    final callable = _functions.httpsCallable('postResponse');
    await callable.call({
      'queryId': queryId,
      'description': description,
      'mentionedUid': mentionedUid,
      'mentionedName' : mentionedName
    });
  }

  Future<void> deleteResponse({
    required String queryId,
    required String responseId,
  }) async {
    final callable = _functions.httpsCallable('deleteResponse');
    await callable.call({'queryId': queryId, 'responseId': responseId});
  }
}
