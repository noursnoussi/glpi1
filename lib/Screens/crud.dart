// lib/Screens/crud.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class CrudScreen extends StatefulWidget {
  const CrudScreen({super.key});

  @override
  State<CrudScreen> createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen> {
  final CollectionReference laptopsCollection =
      FirebaseFirestore.instance.collection('parc_informatique_laptops');

  // --- Ouvrir le formulaire pour ajouter ou modifier ---
  void _openForm({DocumentSnapshot? doc}) {
    final isEditing = doc != null;

    final TextEditingController categorieController =
        TextEditingController(text: doc?['Categorie'] ?? '');
    final TextEditingController memoireController =
        TextEditingController(text: doc?['Composants - Mémoire'] ?? '');
    final TextEditingController processeurController =
        TextEditingController(text: doc?['Composants - Processeur'] ?? '');
    final TextEditingController locationController =
        TextEditingController(text: doc?['Location'] ?? '');
    final TextEditingController manufacturerController =
        TextEditingController(text: doc?['Manufacturer'] ?? '');
    final TextEditingController nameController =
        TextEditingController(text: doc?['Name'] ?? '');
    final TextEditingController serialController =
        TextEditingController(text: doc?['Numéro de serie'] ?? '');
    final TextEditingController productController =
        TextEditingController(text: doc?['Product number'] ?? '');
    final TextEditingController sourceController =
        TextEditingController(text: doc?['Source de mise à jour'] ?? '');
    final TextEditingController statusController =
        TextEditingController(text: doc?['Status'] ?? '');
    final TextEditingController typeController =
        TextEditingController(text: doc?['Type'] ?? '');
    final TextEditingController usersController =
        TextEditingController(text: doc?['Users'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? "Modifier l'appareil" : "Ajouter un appareil"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('Catégorie', categorieController),
                _buildTextField('Mémoire', memoireController),
                _buildTextField('Processeur', processeurController),
                _buildTextField('Location', locationController),
                _buildTextField('Manufacturer', manufacturerController),
                _buildTextField('Name', nameController),
                _buildTextField('Numéro de série', serialController),
                _buildTextField('Product number', productController),
                _buildTextField('Source de mise à jour', sourceController),
                _buildTextField('Status', statusController),
                _buildTextField('Type', typeController),
                _buildTextField('Users', usersController),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final data = {
                  'Categorie': categorieController.text,
                  'Composants - Mémoire': memoireController.text,
                  'Composants - Processeur': processeurController.text,
                  'Location': locationController.text,
                  'Manufacturer': manufacturerController.text,
                  'Name': nameController.text,
                  'Numéro de serie': serialController.text,
                  'Product number': productController.text,
                  'Source de mise à jour': sourceController.text,
                  'Status': statusController.text,
                  'Type': typeController.text,
                  'Users': usersController.text,
                };

                if (isEditing) {
                  await laptopsCollection.doc(doc!.id).update(data);
                } else {
                  await laptopsCollection.add(data);
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: Text(isEditing ? 'Modifier' : 'Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  // --- Supprimer un document ---
  void _deleteDocument(String id) async {
    await laptopsCollection.doc(id).delete();
  }

  // --- Widget de champ de texte ---
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: const Text(
          'Gérer les appareils',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: laptopsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("Aucun appareil trouvé."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    doc['Product number'] ?? 'Sans nom',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${doc['Manufacturer'] ?? ''} - ${doc['Type'] ?? ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _openForm(doc: doc),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteDocument(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
