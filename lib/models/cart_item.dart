class CartItem {
  final String id;
  final String titre;
  final double prix;
  final String image;
  final String taille;
  int quantite;

  CartItem({
    required this.id,
    required this.titre,
    required this.prix,
    required this.image,
    required this.taille,
    this.quantite = 1,
  });

  double get totalPrix => prix * quantite;
}