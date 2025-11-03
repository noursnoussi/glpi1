// lib/Services/auth_service.dart

class AuthService {
  // Simule un utilisateur connecté (null = pas connecté)
  static Map<String, String>? _currentUser;

  // 🔹 LOGIN - Vérifie les identifiants
  Future<bool> login(String email, String password) async {
    // Simule un délai réseau
    await Future.delayed(const Duration(seconds: 1));
    
    // Vérifie les identifiants (tu peux ajouter d'autres utilisateurs)
    if (email == "nour" && password == "nour") {
      // Stocke les infos de l'utilisateur connecté
      _currentUser = {
        'email': email,
        'name': 'Nour Snoussi',
      };
      return true;
    }
    
    return false; // Login échoué
  }

  // 🔹 LOGOUT - Déconnecte l'utilisateur
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null; // Efface les données de l'utilisateur
  }

  // 🔹 Vérifie si un utilisateur est connecté
  bool isLoggedIn() {
    return _currentUser != null;
  }

  // 🔹 Récupère les infos de l'utilisateur connecté
  Map<String, String>? getCurrentUser() {
    return _currentUser;
  }

  // 🔹 Récupère le nom de l'utilisateur
  String? getUserName() {
    return _currentUser?['name'];
  }

  // 🔹 Récupère l'email de l'utilisateur
  String? getUserEmail() {
    return _currentUser?['email'];
  }
}