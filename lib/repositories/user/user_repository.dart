import 'package:cloud_functions/cloud_functions.dart';
import '../../models/user_model.dart';

class UserRepository {
  final _functions = FirebaseFunctions.instanceFor(region: 'asia-south1');

  Future<UserModel> fetchProfile() async {
    final callable = _functions.httpsCallable('getProfile');
    final result = await callable.call();

    final data = Map<String, dynamic>.from(result.data as Map);
    return UserModel.fromMap(data);
  }

  Future<void> updateProfile({
    required String name,
    required String campus,
    required String semester,
  }) async {
    final callable = _functions.httpsCallable('updateProfile');
    await callable.call({'name': name, 'campus': campus, 'semester': semester});
  }
}
