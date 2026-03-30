import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/business_constants.dart';
import '../../models/query_model.dart';
import '../auth/auth_repository.dart';

class QueriesRepository {
  final _functions = FirebaseFunctions.instanceFor(region: "asia-south1");
  final _firestore = FirebaseFirestore.instance;

  Future<List<QueryModel>> fetchQueries({String? startAfterId}) async {
    final uid = AuthRepository().currentUser?.uid;
    if (uid == null) {
      throw FirebaseAuthException(
        code: 'unauthenticated',
        message: 'Please login to continue',
      );
    }

    // Fetch user profile for campus + profileComplete check
    final userDoc = await _firestore.collection('users').doc(uid).get();

    if (!userDoc.exists || userDoc.data() == null) {
      throw FirebaseException(
        plugin: 'queries_repository',
        code: 'not-found',
        message: 'Please set your profile first!',
      );
    }

    final userData = userDoc.data()!;

    if (userData['profileComplete'] != true) {
      throw FirebaseException(
        plugin: 'queries_repository',
        code: 'failed-precondition',
        message: 'Please complete your profile to continue.',
      );
    }

    final campus = userData['campus'] as String?;
    if (campus == null || campus.isEmpty) {
      throw FirebaseException(
        plugin: 'queries_repository',
        code: 'failed-precondition',
        message: 'No campus set. Please check your profile or contact support.',
      );
    }

    // Build query
    Query query = _firestore
        .collection('queries')
        .where('campus', whereIn: [campus, 'All'])
        .where('isResolved', isEqualTo: false)
        .orderBy('postedAt', descending: true)
        .limit(BusinessConstants.queryFetchLimit);

    // Pagination cursor
    if (startAfterId != null) {
      final cursorDoc = await _firestore
          .collection('queries')
          .doc(startAfterId)
          .get();

      if (!cursorDoc.exists) {
        return []; // cursor deleted — silent empty return
      }

      query = query.startAfterDocument(cursorDoc);
    }

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      return QueryModel.fromMap(
        Map<String, dynamic>.from(doc.data() as Map),
        doc.id,
      );
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

  Future<List<QueryModel>> fetchMyQueries({String? startAfterId}) async {
    final uid = AuthRepository().currentUser?.uid;
    if (uid == null) {
      throw FirebaseAuthException(
        code: 'unauthenticated',
        message: 'Please login to continue',
      );
    }

    Query query = _firestore
        .collection('queries')
        .where('postedBy.uid', isEqualTo: uid)
        .orderBy('postedAt', descending: true)
        .limit(BusinessConstants.queryFetchLimit);

    if (startAfterId != null) {
      final cursorDoc = await _firestore
          .collection('queries')
          .doc(startAfterId)
          .get();

      if (!cursorDoc.exists) return []; // cursor deleted — silent empty return

      query = query.startAfterDocument(cursorDoc);
    }

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      return QueryModel.fromMap(
        Map<String, dynamic>.from(doc.data() as Map),
        doc.id,
      );
    }).toList();
  }
}
