import 'package:air_query/repositories/auth/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentUidProvider = Provider<String?>((ref) {
  return AuthRepository().currentUser?.uid;
});