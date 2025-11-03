// lib/utils/constants.dart
// -------------------------------------------------------------
// Contient les valeurs fixes globales : couleurs, textes, tailles, etc.
// -------------------------------------------------------------

import 'package:flutter/material.dart';

// Couleurs globales de l'application
class AppColors {
  static const primary = Color(0xFF0066CC);
  static const background = Color(0xFFF5F8FF);
  static const secondary = Color(0xFF00BFA6);
  static const textPrimary = Color(0xFF333333);
  static const textSecondary = Color(0xFF777777);
}

// Textes statiques (titres, labels, etc.)
class AppStrings {
  static const appName = "GLPI Tech Scanner";
  static const loginTitle = "Connexion Technicien";
  static const loginButton = "Se connecter";
  static const scanHint = "Scannez le QR code du matériel";
  static const homeTitle = "Tableau de bord";
}
class AppSizes {
  static const padding = 16.0;
  static const borderRadius = 8.0;
}
