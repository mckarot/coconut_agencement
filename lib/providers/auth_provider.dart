import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;

  User? get user => _user;

  bool get isAuthenticated => _user != null;

  String? get userId => _user?.uid;

  String? get userEmail => _user?.email;

  // Stream to track user authentication state
  Stream<AuthProvider> get authStateChanges {
    return _authService.user.map((firebaseUser) {
      _user = firebaseUser;
      notifyListeners();
      return this;
    });
  }

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _authService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Register with email and password
  Future<void> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      await _authService.registerWithEmailAndPassword(email, password);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}