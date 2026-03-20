import 'dart:async';
import 'package:air_query/core/constants/campuses.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../repositories/user/user_repository.dart';

class FcmService {
  final _messaging = FirebaseMessaging.instance;
  final _functions = FirebaseFunctions.instanceFor(region: "asia-south1");
  StreamSubscription? _tokenRefreshSub;

  Future<void> init() async {
    await _messaging.requestPermission();

    // Save current token
    final token = await _messaging.getToken();
    if (token != null) await _saveToken(token);

    // Save when token rotates
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _messaging.onTokenRefresh.listen(
      (token) => _saveToken(token),
    );
  }

  Future<void> _saveToken(String token) async {
    await _functions.httpsCallable('saveFcmToken').call({'token': token});
  }

  Future<void> deleteToken() async {
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;

    await _messaging.deleteToken();
    await _functions.httpsCallable('deleteFcmToken').call();
  }
}
