import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _pseduoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late Client _client;
  late Account _account;

  @override
  void initState() {
    super.initState();
    _client = Client()
        .setEndpoint('https://appwrite.thimotebois.ovh/v1')
        .setProject('66178c2b1086e66b625a');
    _account = Account(_client);
  }

  Future<void> _registerUser() async {
    try {
      await _account.create(
        email: _emailController.text,
        password: _passwordController.text,
        name: _pseduoController.text,
        userId: 'unique()',
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Inscription réussie'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur d\'inscription : $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _pseduoController,
              decoration: const InputDecoration(labelText: 'Pseudo'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _registerUser,
              child: const Text('S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}
