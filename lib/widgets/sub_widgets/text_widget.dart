import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  final String text;
  const TextWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0), // Ajoutez un peu de padding autour du texte
      decoration: BoxDecoration(
        color: Colors.lightBlue, // La couleur peut être ajustée selon l'émetteur
        borderRadius: BorderRadius.circular(12.0), // Bords arrondis pour la bulle de texte
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.5, // Limite à la moitié de la largeur de l'écran
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white), // Style du texte, ajustez selon vos besoins
        ),
      ),
    );
  }
}
