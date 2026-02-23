import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final _firebaseAuth = FirebaseAuth.instance;

  // (let bloc catch exceptions - don't handle it here)

  // login
  Future<User?> login({required String email, required String password}) async {
    final userCred = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCred.user;
  }

  // register
  Future<User?> register({
    required String email,
    required String password,
  }) async {
    final userCred = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCred.user;
  }
}
