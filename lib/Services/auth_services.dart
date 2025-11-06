// lib/Services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔹 Créer un compte utilisateur
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await result.user?.sendEmailVerification();
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Erreur signUp: ${e.message}');
      return null;
    }
  }

  // 🔹 Connexion utilisateur
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Erreur signIn: ${e.message}');
      return null;
    }
  }

  // 🔹 Réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Erreur resetPassword: $e');
    }
  }

  // 🔹 Mettre à jour le nom et la photo de profil
  Future<void> updateProfile({String? name, String? photoUrl}) async {
    final user = _auth.currentUser;
    if (user != null) {
      if (name != null && name.isNotEmpty) {
        await user.updateDisplayName(name);
      }
      if (photoUrl != null && photoUrl.isNotEmpty) {
        await user.updatePhotoURL(photoUrl);
      }
      await user.reload();
    }
  }

  // 🔹 Récupérer l'utilisateur actuel
  User? getCurrentUser() => _auth.currentUser;

  // 🔹 Vérifier si l'email est vérifié
  bool isEmailVerified() => _auth.currentUser?.emailVerified ?? false;

  // 🔹 Déconnexion
  Future<void> logout() async {
    await _auth.signOut();
  }

  // 🔹 Stream d’état d’authentification (écoute les changements de connexion)
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  // 🔹 Renvoyer l'email de vérification
Future<bool> resendVerificationEmail() async {
  try {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      return true;
    }
    return false;
  } catch (e) {
    print('Erreur resendVerificationEmail: $e');
    return false;
  }
}
}
