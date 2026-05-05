import 'package:air_query/repositories/auth/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        role: '',
        about: '',
        isInsider: false,
        queriesPosted: 0,
        responsesPosted: 0,
        queriesResolved: 0,
        profileComplete: false,
        isPremium: false,
        createdAt: DateTime.now(),
      );
    }

    return UserModel.fromMap({'uid': uid, ...doc.data()!});
  }

  Future<void> updateProfile({
    required String name,
    required String role,
    required String about,
  }) async {
    final callable = _functions.httpsCallable('updateProfile');
    await callable.call({'name': name, 'role': role, 'about': about});
  }

  // for other user profile
  Future<UserModel> fetchOtherUserProfile(String uid) async {
    final doc = await _firestore.collection("users").doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      throw FirebaseException(
        plugin: 'user_repository',
        code: 'not-found',
        message: 'User not found.',
      );
    }
    return UserModel.fromMap({"uid": uid, ...doc.data()!});
  }
}
