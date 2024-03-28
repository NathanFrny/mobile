import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late Client _client;
  late Account _account;

  @override
  void initState() {
    super.initState();
    _client = Client()
        .setEndpoint('https://appwrite.thimotebois.ovh:9443/v1')
        .setProject('66009da23c66a5968ef9')
        .setSelfSigned(status: true);
    _account = Account(_client);
  }

  Future<void> _loginUser() async {
    try {
      final result = await _account.createEmailPasswordSession(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Connexion réussie
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Connexion réussie'),
      ));
    } catch (e) {
      // Gestion des erreurs de connexion
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur de connexion : $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
              onPressed: _loginUser,
              child: const Text('Connexion'),
            ),
          ],
        ),
      ),
    );
  }
}
