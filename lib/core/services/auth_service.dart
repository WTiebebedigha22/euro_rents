import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 🔹 Register
  Future<User?> register({
    required String email,
    required String password,
    required String name,
    required String username,
    String? phone,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await _firestore.collection("users").doc(user.uid).set({
          "name": name,
          "username": username,
          "email": email,
          "phone": phone ?? "",
          "profilePic": "",
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseError(e));
    }
  }

  // 🔹 Login
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await _ensureUserDoc(user);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseError(e));
    }
  }

  // 🔹 Logout
  Future<void> logout() async => await _auth.signOut();

  // 🔹 Reset password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseError(e));
    }
  }

  // 🔹 Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection("users").doc(user.uid).delete();
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseError(e));
    }
  }

  // 🔹 Update profile
  Future<void> updateUserProfile({
    String? name,
    String? username,
    String? phone,
    String? profilePic,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No logged in user.");

    final updates = <String, dynamic>{};

    if (name != null && name.isNotEmpty) updates["name"] = name;
    if (username != null && username.isNotEmpty) updates["username"] = username;
    if (phone != null && phone.isNotEmpty) updates["phone"] = phone;
    if (profilePic != null && profilePic.isNotEmpty) {
      updates["profilePic"] = profilePic;
    }

    if (updates.isNotEmpty) {
      updates["updatedAt"] = FieldValue.serverTimestamp();
      await _firestore.collection("users").doc(user.uid).update(updates);
    }

    // 🔹 Optionally sync FirebaseAuth display name & photo
    if (name != null || profilePic != null) {
      await user.updateDisplayName(name);
      await user.updatePhotoURL(profilePic);
    }
  }

  // 🔹 Ensure Firestore doc exists (for login users without profile)
  Future<void> _ensureUserDoc(User user) async {
    final docRef = _firestore.collection("users").doc(user.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        "name": user.displayName ?? "New User",
        "username": user.email?.split('@').first ?? "user",
        "email": user.email,
        "phone": "",
        "profilePic": user.photoURL ?? "",
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }

  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case "invalid-email":
        return "The email address is invalid.";
      case "user-disabled":
        return "This account has been disabled.";
      case "user-not-found":
        return "No account found for this email.";
      case "wrong-password":
        return "Incorrect password.";
      case "email-already-in-use":
        return "Email already in use.";
      case "weak-password":
        return "Password is too weak.";
      default:
        return "Authentication error: ${e.message}";
    }
  }
}
