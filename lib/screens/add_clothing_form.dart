import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vetement_ia/screens/home_page.dart';
import '../services/clothing_classifier_service.dart';

class AddClothingForm extends StatefulWidget {
  const AddClothingForm({Key? key}) : super(key: key);

  @override
  _AddClothingFormState createState() => _AddClothingFormState();
}

class _AddClothingFormState extends State<AddClothingForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('clothes');
  final picker = ImagePicker();

  Uint8List? _imageBytes;
  String? _predictedCategory;
  bool _isLoading = false;

  Future<void> _getImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Lire les bytes de l'image
        final bytes = await pickedFile.readAsBytes();
        
        setState(() {
          _imageBytes = bytes;
          _isLoading = true;
        });

        // Classifier l'image avec l'API
        final result = await ClothingClassifierService.classifyImage(_imageBytes!);
        
        setState(() {
          _predictedCategory = result['category'];
          _categoryController.text = _predictedCategory ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _predictedCategory = 'Erreur de classification';
        _categoryController.text = _predictedCategory ?? '';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la classification')),
      );
    }
  }

  Future<void> _addArticle() async {
    if (_formKey.currentState!.validate() && _imageBytes != null && _predictedCategory != null) {
      try {
        // Créer le nouveau vêtement
        Map<String, dynamic> newClothing = {
          'titre': _titleController.text,
          'tailles': [_sizeController.text], // Liste des tailles
          'marque': _brandController.text,
          'prix': double.parse(_priceController.text),
          'categorie': _predictedCategory,
          // Convertir les bytes en base64 pour l'affichage
          'image': base64Encode(_imageBytes!),
        };

        // Ajouter à la base de données
        await _dbRef.push().set(newClothing);

        // Retourner à la HomePage avec mise à jour
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
          (route) => false,
        );

      } catch (e) {
        print('Erreur: $e');
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs et ajouter une image'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un article'),
        backgroundColor: const Color(0xFF1E90FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section Image
                GestureDetector(
                  onTap: _getImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _imageBytes == null
                        ? const Center(child: Text('Appuyez pour ajouter une image'))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              _imageBytes!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Titre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Ce champ est requis' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie (prédite)',
                      border: OutlineInputBorder(),
                    ),
                    enabled: false,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _sizeController,
                    decoration: const InputDecoration(
                      labelText: 'Taille',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Ce champ est requis' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _brandController,
                    decoration: const InputDecoration(
                      labelText: 'Marque',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Ce champ est requis' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Prix',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ce champ est requis';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Veuillez entrer un nombre valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _addArticle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E90FF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Valider',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sizeController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
