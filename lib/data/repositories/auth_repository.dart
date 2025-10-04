import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Sign In
  Future<User?> signIn(String email, String password) async {
    final userCred = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCred.user;
  }

  // Register
  Future<User?> register(String email, String password, {String? displayName}) async {
    final userCred = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (displayName != null && userCred.user != null) {
      await userCred.user!.updateDisplayName(displayName);
    }
    return userCred.user;
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Stream auth changes
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();
}
