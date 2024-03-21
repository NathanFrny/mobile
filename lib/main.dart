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
        appBar: AppBar(
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Container()), // Widget flexible pour pousser les boutons en bas
            const Padding(
              padding: EdgeInsets.only(bottom: 50), // Ajout du padding vers le bas
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
      ),
    );
  }
}
