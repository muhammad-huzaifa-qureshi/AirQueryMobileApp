import 'package:air_query/core/constants/campuses.dart';
import 'package:air_query/repositories/auth/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/business_constants.dart';
import '../../models/user_model.dart';

class UserRepository {
  final _functions = FirebaseFunctions.instanceFor(region: 'asia-south1');
  final _firestore = FirebaseFirestore.instance;

  Future<UserModel> fetchProfile() async {
    final uid = AuthRepository().currentUser?.uid;
    if (uid == null) {
      throw FirebaseAuthException(
        code: 'unauthenticated',
        message: "Please login to continue",
      );
    }

    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      // No doc yet
      return UserModel(
        uid: uid,
        name: '',
        campus: '',
        semester: '',
        queriesPosted: 0,
        queriesAnswered: 0,
        queriesResolved: 0,
        profileComplete: false,
      );
    }

    return UserModel.fromMap({'uid': uid, ...doc.data()!});
  }

  Future<void> updateProfile({
    String? name,
    String? campus,
    String? semester,
  }) async {
    final uid = AuthRepository().currentUser?.uid;
    if (uid == null) {
      throw FirebaseAuthException(
        code: 'unauthenticated',
        message: 'Please login to continue',
      );
    }

    // At least one field required
    if (name == null && campus == null && semester == null) {
      throw FirebaseException(
        plugin: 'user_repository',
        code: 'invalid-argument',
        message: 'Please provide at least one field to update.',
      );
    }

    // Validate name if provided
    if (name != null) {
      if (name.length < BusinessConstants.nameMinChars) {
        throw FirebaseException(
          plugin: 'user_repository',
          code: 'invalid-argument',
          message:
              'Name must be at least ${BusinessConstants.nameMinChars} characters.',
        );
      }
      if (name.length > BusinessConstants.nameMaxChars) {
        throw FirebaseException(
          plugin: 'user_repository',
          code: 'invalid-argument',
          message:
              'Name must not exceed ${BusinessConstants.nameMaxChars} characters.',
        );
      }
    }

    // Validate semester if provided
    if (semester != null) {
      final semNum = int.tryParse(semester);
      if (semNum == null || semNum < 1 || semNum > 8) {
        throw FirebaseException(
          plugin: 'user_repository',
          code: 'invalid-argument',
          message: 'Semester must be between 1 and 8.',
        );
      }
    }

    // Validate campus if provided
    if (campus != null && !Campuses.list.contains(campus)) {
      throw FirebaseException(
        plugin: 'user_repository',
        code: 'invalid-argument',
        message: 'Invalid campus selected.',
      );
    }

    // Build update map
    final updates = <String, dynamic>{
      'profileComplete': true,
      'name': ?name,
      'campus': ?campus,
      'semester': ?semester,
    };

    // Direct write to Firestore
    await _firestore
        .collection('users')
        .doc(uid)
        .set(updates, SetOptions(merge: true));

    // Sync name only if name changed
    if (name != null) {
      await _functions.httpsCallable('syncUserName').call({'name': name});
    }
  }

  // for other user profile
  Future<UserModel> fetchOtherUserProfile(String uid) async {
    final callable = _functions.httpsCallable('getOtherUserProfile');
    final result = await callable.call({'uid': uid});

    final data = Map<String, dynamic>.from(result.data as Map);
    return UserModel.fromMap(data);
  }
}
