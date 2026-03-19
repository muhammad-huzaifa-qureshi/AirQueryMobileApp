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

    // Re-subscribe to campus topic on every init (handles cases like device change)
    try {
      final profile = await UserRepository().fetchProfile();
      if (profile.campus.isNotEmpty) {
        await subscribeToTopic(profile.campus);
      }
    } catch (_) {
      // silently fail — user may not have profile yet
    }
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

  Future<void> subscribeToTopic(String campus) async {
    // Unsubscribe from all campus topics first
    for (final c in Campuses.list) {
      await _messaging.unsubscribeFromTopic(_topicFromCampus(c));
    }
    // Subscribe to new campus + all
    await _messaging.subscribeToTopic(_topicFromCampus(campus));
    await _messaging.subscribeToTopic('campus_all');
  }

  String _topicFromCampus(String campus) {
    return 'campus_${campus.toLowerCase().replaceAll(' ', '_')}';
  }
}
