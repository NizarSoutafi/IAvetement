import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_clothing_form.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _database = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;

  final _emailController = TextEditingController();
  //Firebase, pour des raisons de sécurité, 
  //ne permet pas de récupérer le mot de passe actuel de l'utilisateur
  final _passwordController = TextEditingController(text: '******'); 
  final _anniversaireController = TextEditingController();
  final _adresseController = TextEditingController();
  final _codePostalController = TextEditingController();
  final _villeController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Initialiser l'email depuis Firebase Auth
    _emailController.text = _auth.currentUser?.email ?? '';
  }

  void _handleLogout() {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => Login()),
    (route) => false
  );
}

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _anniversaireController.dispose();
    _adresseController.dispose();
    _codePostalController.dispose();
    _villeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await _database.child('users/$userId').get();
      
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _anniversaireController.text = data['anniversaire'] ?? '';
          _adresseController.text = data['adresse'] ?? '';
          _codePostalController.text = data['code_postal'] ?? '';
          _villeController.text = data['ville'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserData() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSaving = true);

  try {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Mettre à jour les informations de l'utilisateur dans la base de données
    await _database.child('users/$userId').update({
      'anniversaire': _anniversaireController.text,
      'adresse': _adresseController.text,
      'code_postal': _codePostalController.text,
      'ville': _villeController.text,
    });

    // Gérer le changement de mot de passe
    if (_passwordController.text.isNotEmpty && _passwordController.text != '******') {
      try {
        await _auth.currentUser?.updatePassword(_passwordController.text);
        // Remettre les astérisques après le changement
        _passwordController.text = '******';
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du changement de mot de passe. Le mot de passe doit contenir au moins 6 caractères.')),
        );
        setState(() => _isSaving = false);
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil mis à jour avec succès')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
    );
  } finally {
    setState(() => _isSaving = false);
  }
}

Widget _buildAddClothingButton(BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 16.0),
    child: ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddClothingForm()),
        );
      },
      icon: Icon(Icons.add_circle_outline),
      label: Text('Ajouter un vêtement'),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
  );
}

  @override
Widget build(BuildContext context) {
  if (_isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Text(
        'Mon Profil',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextButton(
            onPressed: _handleLogout,
            child: Text(
              'Se déconnecter',
              style: TextStyle(
                color: _isSaving ? Colors.grey : Colors.blue,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Login',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0xFFEEEEEE),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color.fromARGB(255, 233, 230, 230),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _anniversaireController,
                  decoration: const InputDecoration(
                    labelText: 'Anniversaire',
                    hintText: 'JJ/MM/AAAA',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _adresseController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _codePostalController,
                  decoration: const InputDecoration(
                    labelText: 'Code postal',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _villeController,
                  decoration: const InputDecoration(
                    labelText: 'Ville',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),

                // Nouveau bouton pour ajouter un vêtement
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddClothingForm()),
                    );
                  },
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Ajouter un vêtement',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue, // Vous pouvez ajuster la couleur
                  ),
                ),
                const SizedBox(height: 16),

                // Bouton de validation
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveUserData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Valider',
                    style: TextStyle(
                      color: Color.fromARGB(255, 68, 214, 134),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}