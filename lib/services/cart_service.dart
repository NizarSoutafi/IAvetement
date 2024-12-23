import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  
  double get total => _items.fold(0, (sum, item) => sum + item.totalPrix);

  void addItem(Map<String, dynamic> vetement) {
    //Verifie que les donnees ne sont pas nulles
     if (vetement['id'] == null ||
      vetement['titre'] == null ||
      vetement['prix'] == null ||
      vetement['image'] == null ||
      vetement['tailles'] == null ||  // Vérification des tailles
      (vetement['tailles'] as List).isEmpty) {  // Vérification que la liste n'est pas vide
    print('Données du vêtement incomplètes: $vetement');
    return;
  }
  // Ajouter un nouvel article au panier
  try {
    _items.add(
      CartItem(
        id: vetement['id'].toString(),
        titre: vetement['titre'].toString(),
        taille: (vetement['tailles'] as List).first.toString(),  // Prendre la première taille
        prix: double.parse(vetement['prix'].toString()),
        image: vetement['image'].toString(),
      ),
    );
    notifyListeners();
  } catch (e) {
    print('Erreur lors de l\'ajout au panier: $e');
  }
}

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeItem(index);
    } else {
      _items[index].quantite = quantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}