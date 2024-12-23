import 'package:flutter/material.dart';
import '../models/vetement.dart';


class VetementDetailScreen extends StatefulWidget {
  final Vetement vetement;

  const VetementDetailScreen({Key? key, required this.vetement})
      : super(key: key);

  @override
  _VetementDetailScreenState createState() => _VetementDetailScreenState();
}

class _VetementDetailScreenState extends State<VetementDetailScreen> {
  String? selectedTaille;
  String? selectedCouleur;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vetement.titre),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.vetement.image,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.vetement.titre,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${widget.vetement.prix.toStringAsFixed(2)} €',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tailles disponibles',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: widget.vetement.tailles
                        .map((taille) => ChoiceChip(
                              label: Text(taille),
                              selected: selectedTaille == taille,
                              onSelected: (selected) {
                                setState(() {
                                  selectedTaille = selected ? taille : null;
                                });
                              },
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: (selectedTaille != null && selectedCouleur != null)
              ? () {
                  // Ajouter au panier
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ajouté au panier'),
                    ),
                  );
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Ajouter au panier'),
          ),
        ),
      ),
    );
  }
}