import 'dart:async';
import 'package:air_query/core/constants/business_constants.dart';
import 'package:air_query/repositories/auth/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  final _messaging = FirebaseMessaging.instance;
  final _firestore = FirebaseFirestore.instance;
  StreamSubscription? _tokenRefreshSub;

  DocumentReference? get _fcmDoc {
    final uid = AuthRepository().currentUser?.uid;
    if (uid == null) return null;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('private')
        .doc('fcmToken');
  }

  Future<void> init() async {
    await _messaging.requestPermission();

    // Save current token
    final token = await _messaging.getToken();
    if (token != null) await _saveToken(token);

    // Subscribe to the global topic
    await _messaging.subscribeToTopic(BusinessConstants.fcmTopicAllUsers);

    // Save when token rotates
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _messaging.onTokenRefresh.listen(
      (token) => _saveToken(token),
    );
  }

  Future<void> _saveToken(String token) async {
    final doc = _fcmDoc;
    if (doc == null) return; // silently skip if not logged in
    await doc.set({'token': token});
  }

  Future<void> deleteToken() async {
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;

    // Unsubscribe from global topic
    await _messaging.unsubscribeFromTopic(BusinessConstants.fcmTopicAllUsers);

    await _messaging.deleteToken();

    final doc = _fcmDoc;
    if (doc == null) return; // silently skip if already logged out
    await doc.delete();
  }
}
