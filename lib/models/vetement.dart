// lib/models/vetement.dart
class Vetement {
  final String id;
  final String titre;
  final double prix;
  final List<String> tailles;
  final String image;
  final String categorie;

  Vetement({
    required this.id,
    required this.titre,
    required this.prix,
    required this.tailles,
    required this.image,
    required this.categorie,
  });

  factory Vetement.fromJson(Map<String, dynamic> json) {
    return Vetement(
      id: json['id'],
      titre: json['titre'],
      prix: json['prix'].toDouble(),
      tailles: List<String>.from(json['tailles']),
      image: json['image'],
      categorie: json['categorie'],
    );
  }
}