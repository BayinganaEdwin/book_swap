import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  final FirestoreService _firestore = FirestoreService();
  User? user;

  bool get isSignedIn => user != null && (user?.emailVerified ?? false);
  bool get isSignedInButUnverified => user != null && !(user?.emailVerified ?? false);

  AuthProvider() {
    _service.userChanges.listen((u) {
      user = u;
      notifyListeners();
    });
  }

  Future<void> reloadUser() async {
    await user?.reload();
    user = _service.currentUser;
    notifyListeners();
  }

  Future<void> signUp(String email, String password, String name) async {
    final credential = await _service.signUp(email, password);
    if (credential.user != null) {
      // Save user name to Firestore
      await _firestore.saveUserName(credential.user!.uid, name);
      // Send verification email
      await credential.user?.sendEmailVerification();
      // Reload user to get updated state
      await credential.user?.reload();
      user = credential.user;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    await _service.signIn(email, password);
  }

  Future<void> resendVerificationEmail() async {
    await _service.resendVerificationEmail();
  }

  Future<void> signOut() async {
    await _service.signOut();
  }
}
