// lib/Screens/crud.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class CrudScreen extends StatefulWidget {
  final String collectionName;
  
  const CrudScreen({
    super.key,
    this.collectionName = 'parc_informatique_laptops', // Par défaut
  });

  @override
  State<CrudScreen> createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen> {
  late CollectionReference collection;
  String _searchQuery = '';
  List<String> _allFields = [];
  bool _isLoadingFields = true;

  @override
  void initState() {
    super.initState();
    // Initialiser la collection dynamiquement
    collection = FirebaseFirestore.instance.collection(widget.collectionName);
    _loadDynamicFields();
  }

  // Formater le nom de la collection pour l'affichage
  String get _displayCollectionName {
    return widget.collectionName
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? word[0].toUpperCase() + word.substring(1).toLowerCase() 
            : '')
        .join(' ');
  }

  // 🔥 Charger tous les champs uniques de la collection
  Future<void> _loadDynamicFields() async {
    setState(() => _isLoadingFields = true);
    
    try {
      final snapshot = await collection.get();
      Set<String> fieldsSet = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        fieldsSet.addAll(data.keys);
      }
      
      setState(() {
        _allFields = fieldsSet.toList()..sort();
        _isLoadingFields = false;
      });
    } catch (e) {
      setState(() => _isLoadingFields = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement des champs: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // 📝 Ouvrir le formulaire pour ajouter ou modifier
  void _openForm({DocumentSnapshot? doc}) async {
    final isEditing = doc != null;
    
    if (!isEditing) {
      await _loadDynamicFields();
    }

    List<String> fieldsToShow = _allFields;
    if (isEditing) {
      final docData = doc.data() as Map<String, dynamic>;
      Set<String> combinedFields = {...docData.keys, ..._allFields};
      fieldsToShow = combinedFields.toList()..sort();
    }

    Map<String, TextEditingController> controllers = {};
    final idController = TextEditingController(text: isEditing ? doc.id : '');
    
    for (var field in fieldsToShow) {
      controllers[field] = TextEditingController(
        text: isEditing && doc.data() != null && 
              (doc.data() as Map<String, dynamic>).containsKey(field)
            ? (doc[field] ?? '').toString()
            : '',
      );
    }

    final newFieldController = TextEditingController();
    final newValueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // En-tête
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppSizes.borderRadius),
                          topRight: Radius.circular(AppSizes.borderRadius),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isEditing ? Icons.edit_outlined : Icons.add_circle_outline,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isEditing ? "Modifier l'élément" : "Ajouter un élément",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    // Corps du formulaire
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🆔 Champ ID (uniquement pour l'ajout)
                            if (!isEditing) ...[ 
                              const Text(
                                "ID du document",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildModernTextField(
                                "ID (laissez vide pour auto-généré)",
                                idController,
                                Icons.fingerprint,
                              ),
                              const Divider(height: 32),
                            ],

                            // 📋 Tous les champs existants
                            if (fieldsToShow.isNotEmpty) ...[
                              const Text(
                                "Informations",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...fieldsToShow.map((field) {
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildModernTextField(
                                            field,
                                            controllers[field]!,
                                            _getIconForField(field),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setDialogState(() {
                                              fieldsToShow.remove(field);
                                              controllers.remove(field);
                                            });
                                          },
                                          tooltip: 'Supprimer ce champ',
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],

                            const Divider(height: 32),

                            // ➕ Ajouter un nouveau champ
                            const Text(
                              "Ajouter un nouveau champ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildModernTextField(
                                    "Nom du champ",
                                    newFieldController,
                                    Icons.label_outline,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildModernTextField(
                                    "Valeur",
                                    newValueController,
                                    Icons.text_fields,
                                  ),
                                ),
                                IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  onPressed: () {
                                    if (newFieldController.text.isNotEmpty) {
                                      setDialogState(() {
                                        final newField = newFieldController.text;
                                        fieldsToShow.add(newField);
                                        controllers[newField] = TextEditingController(
                                          text: newValueController.text,
                                        );
                                        newFieldController.clear();
                                        newValueController.clear();
                                      });
                                    }
                                  },
                                  tooltip: 'Ajouter le champ',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Boutons d'action
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(AppSizes.borderRadius),
                          bottomRight: Radius.circular(AppSizes.borderRadius),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close_outlined),
                              label: const Text('Annuler'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                                ),
                              ),
                              icon: Icon(isEditing ? Icons.save_outlined : Icons.add_circle_outline),
                              label: Text(isEditing ? 'Enregistrer' : 'Ajouter'),
                              onPressed: () async {
                                final Map<String, dynamic> data = {};
                                
                                for (var field in fieldsToShow) {
                                  if (controllers[field] != null) {
                                    final value = controllers[field]!.text.trim();
                                    data[field] = value;
                                  }
                                }

                                if (data.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Veuillez remplir au moins un champ'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }

                                try {
                                  if (isEditing) {
                                    await collection.doc(doc.id).set(data, SetOptions(merge: false));
                                  } else {
                                    final customId = idController.text.trim();
                                    if (customId.isNotEmpty) {
                                      final docSnapshot = await collection.doc(customId).get();
                                      if (docSnapshot.exists) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Cet ID existe déjà. Veuillez en choisir un autre.'),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                        }
                                        return;
                                      }
                                      await collection.doc(customId).set(data);
                                    } else {
                                      await collection.add(data);
                                    }
                                  }

                                  await _loadDynamicFields();
                                  
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.check_circle, color: Colors.white),
                                            const SizedBox(width: 12),
                                            Text(isEditing ? 'Élément modifié avec succès' : 'Élément ajouté avec succès'),
                                          ],
                                        ),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Erreur: $e'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 🗑️ Supprimer un document
  void _deleteDocument(String id, String displayName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Confirmer la suppression'),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "$displayName" ?\n\nCette action est irréversible.',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              elevation: 0,
            ),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await collection.doc(id).delete();
        await _loadDynamicFields();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Élément supprimé avec succès'),
                ],
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  // 🎨 Widget de champ de texte moderne
  Widget _buildModernTextField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          border: Border.all(
            color: AppColors.border.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.textSecondary,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
          ),
        ),
      ),
    );
  }

  // 🎯 Obtenir une icône appropriée selon le nom du champ
  IconData _getIconForField(String fieldName) {
    final field = fieldName.toLowerCase();
    if (field.contains('name') || field.contains('nom')) return Icons.badge_outlined;
    if (field.contains('manufacturer') || field.contains('fabricant')) return Icons.business_outlined;
    if (field.contains('type')) return Icons.category_outlined;
    if (field.contains('status') || field.contains('état')) return Icons.info_outlined;
    if (field.contains('date')) return Icons.calendar_today_outlined;
    if (field.contains('product') || field.contains('produit')) return Icons.qr_code_2;
    if (field.contains('serial')) return Icons.numbers;
    if (field.contains('location') || field.contains('lieu')) return Icons.location_on_outlined;
    if (field.contains('client')) return Icons.people_outline;
    if (field.contains('user') || field.contains('utilisateur')) return Icons.person_outline;
    return Icons.text_fields;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _displayCollectionName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDynamicFields,
            tooltip: 'Recharger',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Ajouter',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 2,
      ),
      body: _isLoadingFields
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Chargement de la structure...',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Barre de recherche
                Container(
                  padding: const EdgeInsets.all(AppSizes.padding),
                  color: Colors.white,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                      border: Border.all(
                        color: AppColors.border.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Rechercher...',
                        hintStyle: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                          size: AppSizes.iconSize,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                ),

                // Liste des éléments
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: collection.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: AppColors.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Erreur: ${snapshot.error}',
                                style: const TextStyle(color: AppColors.error),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        );
                      }

                      var docs = snapshot.data!.docs;

                      // Filtrer dynamiquement
                      if (_searchQuery.isNotEmpty) {
                        docs = docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return data.values.any((value) =>
                              value.toString().toLowerCase().contains(_searchQuery));
                        }).toList();
                      }

                      if (docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _searchQuery.isEmpty
                                    ? Icons.inventory_2_outlined
                                    : Icons.search_off,
                                size: 64,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? "Aucun élément trouvé"
                                    : "Aucun résultat",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(AppSizes.padding),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final displayValues = data.entries
                              .take(3)
                              .map((e) => '${e.key}: ${e.value}')
                              .join(' • ');

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                              border: Border.all(
                                color: AppColors.border.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.description_outlined,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                'ID: ${doc.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  displayValues.isNotEmpty
                                      ? displayValues
                                      : 'Aucune donnée',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                    onPressed: () => _openForm(doc: doc),
                                    tooltip: 'Modifier',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _deleteDocument(doc.id, doc.id),
                                    tooltip: 'Supprimer',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
