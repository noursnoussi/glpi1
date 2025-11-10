// lib/utils/constants.dart
// -------------------------------------------------------------
// Contient les valeurs fixes globales : couleurs, textes, tailles, etc.
// -------------------------------------------------------------

import 'package:flutter/material.dart';

// Couleurs globales de l'application (palette moderne)
class AppColors {
  // Couleurs principales - style moderne minimaliste
  static const primary = Color(0xFF1E88E5); // Bleu moderne
  static const background = Color(0xFFFFFFFF); // Fond blanc pur
  static const secondary = Color(0xFF00BFA6);
  
  // Couleurs de texte
  static const textPrimary = Color(0xFF000000); // Noir pour le texte principal
  static const textSecondary = Color(0xFF757575); // Gris pour le texte secondaire
  static const textHint = Color(0xFFBDBDBD); // Gris clair pour les hints
  
  // Couleurs d'interface
  static const inputBackground = Color(0xFFF5F5F5); // Gris très clair pour les champs
  static const border = Color(0xFFE0E0E0); // Bordures subtiles
  static const error = Color(0xFFE53935); // Rouge pour les erreurs
  static const success = Color(0xFF43A047); // Vert pour les succès
}

// Textes statiques (titres, labels, etc.)
class AppStrings {
  static const appName = "GLPI Tech Scanner";
  static const loginTitle = "Login";
  static const loginButton = "Login";
  static const usernameHint = "Username";
  static const passwordHint = "Password";
  static const forgotPassword = "Mot de passe oublié ?";
  static const scanHint = "Scannez le QR code du matériel";
  static const homeTitle = "Tableau de bord";
}

// Tailles et espacements
class AppSizes {
  static const padding = 16.0;
  static const paddingLarge = 24.0;
  static const borderRadius = 12.0;
  static const inputHeight = 54.0;
  static const buttonHeight = 54.0;
  static const iconSize = 22.0;
}