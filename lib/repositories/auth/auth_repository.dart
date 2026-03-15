import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

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

  // send email verification
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    await user.reload();
    await user.sendEmailVerification();
  }

  // send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // reload user
  Future<User?> reloadAndGetUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    await user.reload();
    return _firebaseAuth.currentUser;
  }

  // sign out
  void signOut() {
    _firebaseAuth.signOut();
  }

  // delete account
  Future<void> deleteAccount() async {
    final callable = FirebaseFunctions.instanceFor(
      region: "asia-south1",
    ).httpsCallable('deleteAccount');
    await callable.call();
  }
}
