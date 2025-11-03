// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'scanner_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Liste des pages (importées depuis leurs fichiers respectifs)
  final List<Widget> _pages = [
    const ScannerScreen(), // ✅ Importé de scanner_screen.dart
    const ProfileScreen(), // ✅ Importé de profile_screen.dart
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
    title: Text(
      _currentIndex == 0 ? 'Scanner' : 'Profil',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    centerTitle: true,
    backgroundColor: Colors.blueAccent,
    iconTheme: const IconThemeData(color: Colors.white), // icônes blanches si besoin
  ),

      body: _pages[_currentIndex], // Affiche la page sélectionnée
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scanner',
            
          
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}