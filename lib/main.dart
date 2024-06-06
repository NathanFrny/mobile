import 'package:flutter/material.dart';
import 'package:mobile/widgets/connexion_button.dart';
import 'package:mobile/widgets/navigation.dart';
import 'package:mobile/widgets/register_button.dart';
import 'services/appwrite_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  Future<bool> _checkSession() async {
    final AppwriteService appwriteService = AppwriteService();
    return await appwriteService.checkSession();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Erreur de vérification de session')),
          );
        } else {
          if (snapshot.data == true) {
            return const Navigation();
          } else {
            return const AuthPage();
          }
        }
      },
    );
  }
}

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              const SizedBox(height: 150),
              Image.asset(
                'assets/images/logo.png',
                height: 300,
              ),
              Expanded(child: Container()),
              const Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConnexionButton(),
                    SizedBox(height: 20),
                    RegisterButton(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
