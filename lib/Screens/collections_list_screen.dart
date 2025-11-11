// lib/Screens/collections_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import 'crud.dart';

class CollectionConfig {
  final String name;
  final String displayName;
  final String icon;
  final String color;
  final bool enabled;

  CollectionConfig({
    required this.name,
    required this.displayName,
    required this.icon,
    required this.color,
    this.enabled = true,
  });

  factory CollectionConfig.fromMap(Map<String, dynamic> map) {
    return CollectionConfig(
      name: map['name'] ?? '',
      displayName: map['displayName'] ?? '',
      icon: map['icon'] ?? 'storage_outlined',
      color: map['color'] ?? 'blue',
      enabled: map['enabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'displayName': displayName,
      'icon': icon,
      'color': color,
      'enabled': enabled,
    };
  }
}

class CollectionsListScreen extends StatefulWidget {
  const CollectionsListScreen({super.key});

  @override
  State<CollectionsListScreen> createState() => _CollectionsListScreenState();
}

class _CollectionsListScreenState extends State<CollectionsListScreen> {
  bool _isLoading = true;
  List<CollectionConfig> _collections = [];
  Map<String, int> _collectionCounts = {};

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    setState(() => _isLoading = true);
    
    try {
      final configDoc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('collections_config')
          .get();

      if (configDoc.exists && configDoc.data() != null) {
        final data = configDoc.data()!;
        final collectionsData = data['collections'] as List<dynamic>? ?? [];
        
        _collections = collectionsData
            .map((item) => CollectionConfig.fromMap(item as Map<String, dynamic>))
            .where((config) => config.enabled)
            .toList();
      } else {
        _collections = _getDefaultCollections();
      }

      await _loadCollectionCounts();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erreur de chargement: $e')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        _collections = _getDefaultCollections();
        await _loadCollectionCounts();
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCollectionCounts() async {
    for (CollectionConfig config in _collections) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection(config.name)
            .limit(1000)
            .get();
        _collectionCounts[config.name] = snapshot.docs.length;
      } catch (e) {
        _collectionCounts[config.name] = 0;
      }
    }
    setState(() {});
  }

  List<CollectionConfig> _getDefaultCollections() {
    return [
      CollectionConfig(
        name: 'parc_informatique_laptops',
        displayName: 'Laptops',
        icon: 'laptop_mac',
        color: 'blue',
      ),
      CollectionConfig(
        name: 'parc_informatique_laptops_clients',
        displayName: 'Laptops Clients',
        icon: 'people_outline',
        color: 'green',
      ),
    ];
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'laptop_mac':
        return Icons.laptop_mac;
      case 'people_outline':
        return Icons.people_outline;
      case 'person_outline':
        return Icons.person_outline;
      case 'inventory_2_outlined':
        return Icons.inventory_2_outlined;
      case 'computer_outlined':
        return Icons.computer_outlined;
      case 'devices_outlined':
        return Icons.devices_outlined;
      case 'phone_android':
        return Icons.phone_android;
      case 'tablet_mac':
        return Icons.tablet_mac;
      case 'print_outlined':
        return Icons.print_outlined;
      case 'router_outlined':
        return Icons.router_outlined;
      default:
        return Icons.storage_outlined;
    }
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'red':
        return Colors.red;
      case 'teal':
        return Colors.teal;
      case 'indigo':
        return Colors.indigo;
      case 'pink':
        return Colors.pink;
      default:
        return AppColors.primary;
    }
  }

  void _showAddCollectionDialog() {
    final nameController = TextEditingController();
    final displayNameController = TextEditingController();
    String selectedIcon = 'laptop_mac';
    String selectedColor = 'blue';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Ajouter une collection',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom technique',
                        hintText: 'ex: parc_informatique_laptops',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: displayNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom d\'affichage',
                        hintText: 'ex: Laptops',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.text_fields),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedIcon,
                      decoration: const InputDecoration(
                        labelText: 'Icône',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.palette_outlined),
                      ),
                      items: [
                        'laptop_mac',
                        'people_outline',
                        'computer_outlined',
                        'phone_android',
                        'tablet_mac',
                        'print_outlined',
                        'inventory_2_outlined',
                        'storage_outlined',
                      ].map((icon) {
                        return DropdownMenuItem(
                          value: icon,
                          child: Row(
                            children: [
                              Icon(_getIconFromString(icon), size: 20),
                              const SizedBox(width: 8),
                              Text(icon),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedIcon = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedColor,
                      decoration: const InputDecoration(
                        labelText: 'Couleur',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.color_lens_outlined),
                      ),
                      items: [
                        'blue',
                        'green',
                        'orange',
                        'purple',
                        'red',
                        'teal',
                        'indigo',
                        'pink',
                      ].map((color) {
                        return DropdownMenuItem(
                          value: color,
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _getColorFromString(color),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(color),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedColor = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () async {
                    if (nameController.text.isEmpty || displayNameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez remplir tous les champs'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    final newCollection = CollectionConfig(
                      name: nameController.text.trim(),
                      displayName: displayNameController.text.trim(),
                      icon: selectedIcon,
                      color: selectedColor,
                      enabled: true,
                    );

                    try {
                      final configRef = FirebaseFirestore.instance
                          .collection('app_config')
                          .doc('collections_config');

                      final configDoc = await configRef.get();
                      List<dynamic> collections = [];

                      if (configDoc.exists && configDoc.data() != null) {
                        collections = configDoc.data()!['collections'] ?? [];
                      }

                      collections.add(newCollection.toMap());

                      await configRef.set({
                        'collections': collections,
                        'updated_at': FieldValue.serverTimestamp(),
                      });

                      Navigator.pop(context);
                      await _loadCollections();

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 12),
                                Text('Collection ajoutée avec succès'),
                              ],
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Ajouter',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Bases de données',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false, // 🔥 Pas de bouton retour
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: _showAddCollectionDialog,
            tooltip: 'Ajouter une collection',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadCollections,
            tooltip: 'Recharger',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Chargement des bases...',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadCollections,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSizes.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.cloud_outlined,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Gestion dynamique',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_collections.length} base${_collections.length > 1 ? 's' : ''} active${_collections.length > 1 ? 's' : ''}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.95),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sélectionnez une base',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.sync,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Auto',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),

                    if (_collections.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune collection disponible',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ajoutez une collection pour commencer',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...(_collections.map((config) {
                        final color = _getColorFromString(config.color);
                        final icon = _getIconFromString(config.icon);
                        final count = _collectionCounts[config.name] ?? 0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                            border: Border.all(
                              color: AppColors.border.withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                icon,
                                color: color,
                                size: 28,
                              ),
                            ),
                            title: Text(
                              config.displayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.description_outlined,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$count document${count > 1 ? 's' : ''}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                            onTap: () {
                              // 🔥 Navigation SANS remplacer l'écran
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CrudScreen(
                                    collectionName: config.name,
                                  ),
                                ),
                              ).then((_) {
                                // Recharger après retour
                                _loadCollections();
                              });
                            },
                          ),
                        );
                      }).toList()),
                  ],
                ),
              ),
            ),
    );
  }
}