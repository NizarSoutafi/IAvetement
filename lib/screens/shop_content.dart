import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:vetement_ia/services/cart_service.dart';

// Widget pour le contenu de la boutique
class ShopContent extends StatefulWidget {
  final Map<String, dynamic>? newClothing;
  
  const ShopContent({Key? key, this.newClothing}) : super(key: key);

  @override
  State<ShopContent> createState() => _ShopContentState();
}

class _ShopContentState extends State<ShopContent> {
  final _database = FirebaseDatabase.instance.ref();
  bool _isLoading = true;
  Map<String, List<Map<String, dynamic>>> _categories = {};

  @override
  void initState() {
    super.initState();
    _loadVetements();
     // Ajouter le nouveau vêtement s'il existe
    if (widget.newClothing != null) {
      _addNewClothing(widget.newClothing!);
    }
  }

  void _addNewClothing(Map<String, dynamic> clothing) {
  setState(() {
    // Déterminer la catégorie appropriée
    String categoryKey;
    String categoryTitle;
    switch(clothing['categorie'].toLowerCase()) {
      case 'pull':
        categoryKey = 'pulls';
        categoryTitle = 'Pulls';
        break;
      case 'pantalon':
        categoryKey = 'pantalons';
        categoryTitle = 'Pantalons';
        break;
      case 't-shirt':
        categoryKey = 'tshirts';
        categoryTitle = 'T-Shirts';
        break;
      default:
        // Créer une nouvelle catégorie si elle n'existe pas
        categoryKey = clothing['categorie'].toLowerCase().replaceAll(' ', '_');
        categoryTitle = clothing['categorie'];
    }
    
    // Initialiser la liste si elle n'existe pas
    _categories[categoryKey] ??= [];
    
    // Ajouter le vêtement à la catégorie
    _categories[categoryKey]!.add(clothing);
    
    // Si c'est une nouvelle catégorie, ajouter la section dans le build
    if (!_categories.containsKey(categoryKey)) {
      // La section sera automatiquement ajoutée grâce au setState
      _categories[categoryKey] = [clothing];
    }
  });
}

  Future<void> _loadVetements() async {
    try {
      final snapshot = await _database.child('categories').get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final categories = <String, List<Map<String, dynamic>>>{};

        data.forEach((key, value) {
          if (value is List) {
            categories[key.toString()] = value
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
          }
        });

        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildCategorySection(String title, String categoryKey) {
    final items = _categories[categoryKey] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildVetementCard(context, item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVetementCard(BuildContext context, Map<String, dynamic> vetement) {
  return GestureDetector(
    onTap: () {
      _showVetementDetails(vetement);
    },
    child: Card(
      margin: const EdgeInsets.all(8.0),
      child: Container(
        width: 180,
        // Définir une hauteur fixe pour la carte
        height: 280, // Ajustez cette valeur si nécessaire
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              vetement['image'] ?? '',
              height: 180,
              width: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  width: 180,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
            Expanded( // Utiliser Expanded pour le contenu texte
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                    'Taille: ${(vetement['tailles'] as List<dynamic>).join(', ')}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                    Expanded( // Expanded pour le titre
                      child: Text(
                        vetement['titre'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${vetement['prix']?.toString() ?? '0'} €',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  void _showVetementDetails(Map<String, dynamic> vetement) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  vetement['image'] ?? '',
                  height: 250, // Réduire un peu la hauteur de l'image
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Catégorie: ${vetement['categorie']?.toString().toUpperCase() ?? ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Marque: ${vetement['marque'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vetement['titre'] ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${vetement['prix']?.toString() ?? '0'} €',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tailles disponibles: ${(vetement['tailles'] as List<dynamic>).join(', ')}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final cartService = context.read<CartService>();
                            cartService.addItem(vetement);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ajouté au panier')),
                            );
                            Navigator.pop(context);
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Ajouter au panier'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16), // Ajouter un peu d'espace en bas
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  @override
Widget build(BuildContext context) {
  if (_isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  return RefreshIndicator(
    onRefresh: _loadVetements,
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _categories.entries.map((entry) {
          // Créer une section pour chaque catégorie
          return _buildCategorySection(
            entry.key.substring(0, 1).toUpperCase() + entry.key.substring(1),
            entry.key,
          );
        }).toList(),
      ),
    ),
  );
}
}