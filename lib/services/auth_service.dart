// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to notify the app about authentication changes (login/logout)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get the current user if they are logged in
  User? get currentUser => _auth.currentUser;

  // Sign in with Email & Password (We will use this later)
  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Sign-in successful
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }

  // Register with Email & Password
  Future<String?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null; // Registration successful
    } on FirebaseAuthException catch (e) {
      // Return a user-friendly error message from Firebase
      return e.message;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
