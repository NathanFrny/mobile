import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile/register_page.dart';

class RegisterButton extends StatelessWidget {
  const RegisterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Action à effectuer lorsqu'on appuie sur le bouton
        // Par exemple : afficher un message dans la console
        if (kDebugMode) {
          print('Bouton d\'inscription appuyé');
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const RegisterPage()));
        }
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor:
            const Color.fromRGBO(255, 255, 255, 1), // Couleur du texte
        padding: const EdgeInsets.symmetric(
            horizontal: 52, vertical: 18), // Padding du bouton
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(34), // Bord arrondi du bouton
          side: const BorderSide(
              color: Color.fromRGBO(0, 0, 0, 1),
              width: 2.0), // Bordure du bouton avec une épaisseur de 2.0
        ),
      ),
      child: const Text(
        'S\'inscrire',
        style: TextStyle(
            fontSize: 18,
            fontFamily: 'Roboto',
            color: Colors.black), // Style du texte
      ),
    );
  }
}
