// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../services/appwrite_service.dart'; // Importer le service Appwrite

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final AppwriteService _appwriteService = AppwriteService();
  String _userName = 'Chargement...';
  String _userId = 'Chargement...';
  String _dateCreation = 'Chargement...';

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final userId = await _appwriteService.getCurrentUserId();
      final userName = await _appwriteService.getCurrentUserName();
      final userDocument = await _appwriteService.getUserByID(userId);
      final dateCreation = userDocument.data['Date_creation'];
      // formation la date de création pour avoir un string : 'JJ/MM/AAAA - HH:MM:SS'
      final dateCreationFormatted = DateTime.parse(dateCreation);

      setState(() {
        _userId = userId;
        _userName = userName;
        _dateCreation = dateCreationFormatted.toString();
      });
    } catch (e) {
      setState(() {
        _userName = 'Erreur lors de la récupération du nom';
        _userId = 'Erreur lors de la récupération de l\'ID';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Page'),
        automaticallyImplyLeading: false, // Retire la flèche de retour
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nom : $_userName',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(
              'ID : $_userId',
              style: const TextStyle(fontSize: 24),
            ),
            Text(
              'Date de création : $_dateCreation',
              style: const TextStyle(fontSize: 24),
            )
          ],
        ),
      ),
    );
  }
}
