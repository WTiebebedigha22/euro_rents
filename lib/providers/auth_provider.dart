import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/auth_service.dart';
import '../data/models/user.dart'; 

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _firebaseUser;
  AppUser? _appUser;

  bool _isLoading = false;
  String? _errorMessage;

  User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _firebaseUser != null;
  bool get isAdmin => _appUser?.role == "admin";

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? username,
  }) async {
    _setLoading(true);
    try {
      final newUser = await _authService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
        username: username ?? '',
      );
      _firebaseUser = newUser;

      final appUser = AppUser(
        id: newUser!.uid,
        name: name,
        email: email,
        username: username ?? '',
        phone: phone,
        profileImageUrl: null,
        createdAt: DateTime.now(),
        role: "user",
      );

      await _firestore.collection("users").doc(newUser.uid).set(appUser.toMap());
      _appUser = appUser;

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final loggedInUser = await _authService.login(
        email: email,
        password: password,
      );
      _firebaseUser = loggedInUser;

      if (loggedInUser != null) {
        await _fetchAppUser(loggedInUser.uid);
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  Future<void> logout() async {
    await _authService.logout();
    _firebaseUser = null;
    _appUser = null;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  Future<void> deleteAccount() async {
    _setLoading(true);
    try {
      await _authService.deleteAccount();
      if (_firebaseUser != null) {
        await _firestore.collection("users").doc(_firebaseUser!.uid).delete();
      }
      _firebaseUser = null;
      _appUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  /// 🔹 Fetch AppUser from Firestore
  Future<void> _fetchAppUser(String uid) async {
    final doc = await _firestore.collection("users").doc(uid).get();
    if (doc.exists) {
      _appUser = AppUser.fromMap(doc.data()!, doc.id);
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
