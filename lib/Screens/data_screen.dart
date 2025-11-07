import 'package:flutter/material.dart';
import 'crud.dart';
import 'profile_screen.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final scannedData = args?['scannedData'] ?? 'Aucune donnée';
    final timestamp = args?['timestamp'] as DateTime? ?? DateTime.now();

    final List<Widget> _pages = [
      _buildDataScreenContent(scannedData, timestamp),
      const ProfileScreen(),
      const CrudScreen(),
    ];

    return Scaffold(
      // 👇 ICI on affiche AppBar UNIQUEMENT pour l’index 0
      appBar: _currentIndex == 0
          ? AppBar(
              title: const Text(
                'Données scannées',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.blueAccent,
              centerTitle: true,
            )
          : null, // aucune AppBar pour les autres pages

      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
            icon: Icon(Icons.settings),
            label: 'CRUD',
          ),
        ],
      ),
    );
  }

  // --- Contenu du scanner ---
  Widget _buildDataScreenContent(String scannedData, DateTime timestamp) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Scan réussi !',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Le ${timestamp.day}/${timestamp.month}/${timestamp.year} à ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          const SizedBox(height: 32),
          _buildInfoCard(title: 'Données scannées', icon: Icons.qr_code, content: scannedData.toString()),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Text(content, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
