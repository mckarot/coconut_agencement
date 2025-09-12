import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to track user authentication state
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
            'Cette opération est sensible et nécessite une authentification récente. Veuillez vous reconnecter avant de réessayer.');
      }
      rethrow;
    }
  }

  // Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      // Réauthentifier l'utilisateur avec le mot de passe actuel
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Changer le mot de passe
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Le mot de passe actuel est incorrect');
      } else if (e.code == 'weak-password') {
        throw Exception('Le nouveau mot de passe est trop faible');
      } else if (e.code == 'requires-recent-login') {
        throw Exception(
            'Cette opération est sensible et nécessite une authentification récente. Veuillez vous reconnecter avant de réessayer.');
      }
      rethrow;
    }
  }
}