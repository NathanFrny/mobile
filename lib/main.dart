import 'package:flutter/material.dart';
import 'widgets/connexion_button.dart';
import 'widgets/register_button.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.lightBlue, Color.fromRGBO(00, 00, 52, 1)],
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 150), // Espacement pour le logo
                // Ajouter votre logo ici
                Image.asset(
                  'assets/images/logo.png', // Remplacez 'assets/logo.png' par le chemin de votre logo
                  height: 300, // Ajustez la hauteur du logo selon vos besoins
                ),
                Expanded(
                    child:
                        Container()), // Widget flexible pour pousser les boutons en bas
                const Padding(
                  padding: EdgeInsets.only(
                      bottom: 50), // Ajout du padding vers le bas
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConnexionButton(), // Bouton de connexion
                      SizedBox(height: 20), // Espacement entre les boutons
                      RegisterButton(), // Bouton s'inscrire
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
