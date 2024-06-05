import 'package:flutter/material.dart';
import 'package:mobile/services/appwrite_service.dart';
import 'conversation.dart';

class Channel extends StatefulWidget {
  const Channel({super.key});

  @override
  State<Channel> createState() => _ChannelState();
}

class _ChannelState extends State<Channel> {
  final AppwriteService _appwriteService = AppwriteService();
  List<Map<String, dynamic>> channels = [];
  Set<int> _hoveringIndex = {};

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    try {
      final userId = await _appwriteService.getCurrentUserId();
      final userChannels = await _appwriteService.getUserChannels(userId);

      List<Map<String, dynamic>> loadedChannels = [];

      for (var channelId in userChannels) {
        final channelDetails = await _appwriteService.getChannelById(channelId);
        loadedChannels.add(channelDetails);
      }

      setState(() {
        channels = loadedChannels;
      });
    } catch (e) {
      print('Erreur lors du chargement des channels : $e');
    }
  }

  void _navigateToConversation(BuildContext context, String channelName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Conversation(channelName: channelName),
      ),
    );
  }

  Future<void> _createChannel(String channelName) async {
    try {
      final userId = await _appwriteService.getCurrentUserId();
      final channelCount = await _appwriteService.getChannelCount();
      final channelId = channelCount + 1;

      await _appwriteService.createChannel(channelId, channelName);
      print('Channel créé avec succès dans la base de données.');

      await _appwriteService.addUserChannel(userId, channelId);
      print('Channel ajouté à la liste des channels de l\'utilisateur.');

      await _appwriteService.addUserToChannel(userId, channelId);
      print('Utilisateur ajouté au channel.');

      _loadChannels();
    } catch (e) {
      print('Erreur lors de la création du channel : $e');
    }
  }

  Future<void> _removeUserFromChannel(int channelId) async {
    try {
      final userId = await _appwriteService.getCurrentUserId();
      await _appwriteService.removeUserFromChannel(userId, channelId);

      final channelDetails = await _appwriteService.getChannelById(channelId);
      List<dynamic> users = channelDetails['UsersID'] ?? [];

      if (users.isEmpty) {
        await _appwriteService.deleteChannel(channelId);
        print('Channel supprimé de la base de données.');
      }

      await _appwriteService.removeUserChannel(userId, channelId);
      print('Utilisateur supprimé du channel.');
      _loadChannels();
    } catch (e) {
      print('Erreur lors de la suppression de l\'utilisateur du channel : $e');
    }
  }



  void _showCreateChannelDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _channelNameController = TextEditingController();
        return AlertDialog(
          title: const Text('Créer un channel'),
          content: TextField(
            controller: _channelNameController,
            decoration: const InputDecoration(labelText: 'Nom du channel'),
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
                _createChannel(_channelNameController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Créer'),
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
        title: const Text('Channels'),
      ),
      body: ListView.builder(
        itemCount: channels.length,
        itemBuilder: (context, index) {
          return MouseRegion(
            onEnter: (_) => setState(() => _hoveringIndex.add(index)),
            onExit: (_) => setState(() => _hoveringIndex.remove(index)),
            child: ListTile(
              title: Text(channels[index]['name']),
              trailing: _hoveringIndex.contains(index)
                  ? IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _removeUserFromChannel(int.parse(channels[index]['id'])),
              )
                  : null,
              onTap: () => _navigateToConversation(context, channels[index]['name']),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateChannelDialog,
        tooltip: 'Créer un channel',
        child: const Icon(Icons.add),
      ),
    );
  }
}
