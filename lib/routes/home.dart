// home.dart

import 'package:flutter/material.dart';
import 'package:mobile/services/appwrite_service.dart';
import 'package:mobile/widgets/color_picker.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AppwriteService _appwriteService = AppwriteService();
  String currentUserName = '';
  String profilePicUrl = '';
  bool isHovering = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = await _appwriteService.getCurrentUserId();
    final user = await _appwriteService.getUserByID(userId);
    setState(() {
      currentUserName = user.data['Nom'];
      profilePicUrl = user.data['URL_PP'];
    });
  }

  Future<void> _updateProfilePic(String url) async {
    final userId = await _appwriteService.getCurrentUserId();
    await _appwriteService.setUserPP(userId, url);
    setState(() {
      profilePicUrl = url;
    });
  }

  Future<void> _updateUserName(String newName) async {
    final userId = await _appwriteService.getCurrentUserId();
    await _appwriteService.setUserName(userId, newName);
    setState(() {
      currentUserName = newName;
    });
  }

  void _showProfilePicDialog() {
    final TextEditingController _urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modifier la photo de profil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Entrez l\'URL de la nouvelle image :'),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL de l\'image',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateProfilePic(_urlController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Modifier'),
            ),
          ],
        );
      },
    );
  }

  void _showEditUserNameDialog() {
    final TextEditingController _nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modifier le pseudo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Entrez votre nouveau pseudo :'),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nouveau pseudo',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateUserName(_nameController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Modifier'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Center(
              child: Text(
                'Welcome to the home page!',
                style: TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              backgroundImage: NetworkImage(profilePicUrl),
              radius: 40,
              child: GestureDetector(
                onTap: _showProfilePicDialog,
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            MouseRegion(
              onEnter: (_) {
                setState(() {
                  isHovering = true;
                });
              },
              onExit: (_) {
                setState(() {
                  isHovering = false;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _showEditUserNameDialog,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.translationValues(
                        isHovering ? -10 : 0,
                        0,
                        0,
                      ),
                      child: Text(
                        currentUserName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (isHovering)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.black),
                      onPressed: _showEditUserNameDialog,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Expanded(
              child: ColorPicker(),
            ),
          ],
        ),
      ),
    );
  }
}
