// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'Screens/home_screen.dart';
import 'Screens/login_screen.dart';
import 'Screens/scanner_main_screen.dart';
import 'Screens/data_screen.dart';
import 'Screens/edit_profile_screen.dart';
import 'Screens/reset_password_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),

      // ✅ Changement : La page d'accueil devient la première page
      initialRoute: '/',

      routes: {
        '/': (context) => const HomeScreen(),              // Page d'accueil avec bouton "Se connecter"
        '/login': (context) => const LoginScreen(),        // Page de connexion
        '/scanner': (context) => const ScannerMainScreen(), // Page principale avec Scanner + Profil
        '/data': (context) => const DataScreen(),          // Page d'affichage des données scannées
        '/edit-profile': (context) => const EditProfileScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
      },
    );
  }
}