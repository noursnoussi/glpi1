// lib/screens/scanner_main_screen.dart
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'scanner_screen.dart';
import 'profile_screen.dart';
import 'collections_list_screen.dart';

class ScannerMainScreen extends StatefulWidget {
  const ScannerMainScreen({super.key});

  @override
  State<ScannerMainScreen> createState() => _ScannerMainScreenState();
}

class _ScannerMainScreenState extends State<ScannerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ScannerScreen(),           // index 0 - Scanner
    const ProfileScreen(),            // index 1 - Profil
    const CollectionsListScreen(),    // index 2 - CRUD (Liste des bases)
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
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scanner',
          ),
            BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storage_outlined),
            label: 'BD',
          ),
        ],
      ),
    );
  }
}
