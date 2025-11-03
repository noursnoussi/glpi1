import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../Services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final success = await AuthService().login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Identifiants incorrects'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ✅ Même AppBar que Reset Password
      appBar: AppBar(
        title: const Text(
          'Connexion',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 50),

              // 🛡️ Icône
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Colors.blueAccent,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Bienvenue',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Text(
                'Veuillez vous connecter pour accéder au système',
                style: TextStyle(color: Colors.grey[600], fontSize: 15),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Champ email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (v) => v!.isEmpty ? "Entrez votre email" : null,
              ),

              const SizedBox(height: 15),

              // Champ mot de passe
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Mot de passe",
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (v) => v!.isEmpty ? "Entrez votre mot de passe" : null,
              ),

              const SizedBox(height: 25),

              // ✅ Bouton Login
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Se connecter",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),

              const SizedBox(height: 20),

              // ✅ Lien reset password
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/reset-password');
                },
                child: const Text(
                  "Mot de passe oublié ?",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
