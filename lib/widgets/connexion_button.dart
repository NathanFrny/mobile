import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ConnexionButton extends StatelessWidget {
  const ConnexionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Action à effectuer lorsqu'on appuie sur le bouton
        // Par exemple : afficher un message dans la console
        if (kDebugMode) {
          print('Bouton de connexion appuyé');
        }
      },
      style: ElevatedButton.styleFrom(
        primary: const Color.fromRGBO(49, 66, 218, 1), // Couleur de fond du bouton
        onPrimary: Colors.white, // Couleur du texte
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), // Padding du bouton
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(34), // Bord arrondi du bouton
          side: const BorderSide(color: Color.fromRGBO(0, 0, 0, 1), width: 3.0), // Bordure du bouton avec une épaisseur de 2.0
        ),
      ),
      child: const Text(
        'Se connecter',
        style: TextStyle(fontSize: 18, fontFamily: 'Roboto'), // Style du texte
      ),
    );
  }
}
