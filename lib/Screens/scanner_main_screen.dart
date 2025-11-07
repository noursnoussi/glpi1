// lib/screens/scanner_main_screen.dart
import 'package:flutter/material.dart';
import 'scanner_screen.dart';
import 'profile_screen.dart';
import 'data_screen.dart'; // ✅ on l’importe pour que la page ait aussi la tab bar
import 'crud.dart'; // ✅ ton futur écran CRUD

class ScannerMainScreen extends StatefulWidget {
  const ScannerMainScreen({super.key});

  @override
  State<ScannerMainScreen> createState() => _ScannerMainScreenState();
}

class _ScannerMainScreenState extends State<ScannerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ScannerScreen(), // index 0
    const ProfileScreen(), // index 1
    const CrudScreen(),    // index 2 ✅ nouvelle page CRUD
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
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
          BottomNavigationBarItem(
            icon: Icon(Icons.settings), // ⚙️ icône CRUD
            label: 'CRUD',
          ),
        ],
      ),
    );
  }
}
