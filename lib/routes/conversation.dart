import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/services/appwrite_service.dart';
import 'package:mobile/widgets/message_widget.dart';

class Conversation extends StatefulWidget {
  final String channelName;

  const Conversation({required this.channelName, super.key});

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  final AppwriteService _appwriteService = AppwriteService();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController _messageController = TextEditingController();
  int? channelId;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadChannel();
    if (channelId != null) {
      await _loadMessages();
    }
  }

  Future<void> _loadChannel() async {
    final userId = await _appwriteService.getCurrentUserId();
    channelId = await _appwriteService.getChannelIdByName(userId, widget.channelName);
  }

  Future<void> _loadMessages() async {
    if (channelId == null) return;
    final messagesFromDB = await _appwriteService.getMessagesByChannelId(channelId!);
    setState(() {
      messages.addAll(messagesFromDB);
    });
  }

  Future<void> _addUserToChannel(String username) async {
    try {
      if (channelId == null) return;
      final userId = await _appwriteService.getUserIdByUsername(username);
      await _appwriteService.addUserToChannel(userId, channelId!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur ajouté avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout de l\'utilisateur : $e')),
      );
    }
  }

  Future<void> _sendMessage() async {
    try {
      if (channelId == null || _messageController.text.isEmpty) return;
      final userId = await _appwriteService.getCurrentUserId();
      final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final messageCount = await _appwriteService.getMessageCount();
      final messageId = messageCount + 1;

      await _appwriteService.createMessage(
        messageId,
        userId,
        timestamp,
        _messageController.text,
        channelId!,
      );

      setState(() {
        messages.add({
          "isUser": true,
          "messageText": _messageController.text,
          "profilePicUrl": "https://img-19.commentcamarche.net/WNCe54PoGxObY8PCXUxMGQ0Gwss=/480x270/smart/d8c10e7fd21a485c909a5b4c5d99e611/ccmcms-commentcamarche/20456790.jpg",
          "timestamp": timestamp,
        });
        _listKey.currentState?.insertItem(messages.length - 1);
      });

      _messageController.clear();

      Future<void>.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'envoi du message : $e')),
      );
    }
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _usernameController = TextEditingController();
        return AlertDialog(
          title: const Text('Ajouter un utilisateur'),
          content: TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Nom d\'utilisateur'),
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
                _addUserToChannel(_usernameController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Ajouter'),
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
        title: Text('Channel: ${widget.channelName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddUserDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedList(
              key: _listKey,
              initialItemCount: messages.length,
              itemBuilder: (context, index, animation) {
                final message = messages[index];
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: message["isUser"] ? const Offset(1, 0) : const Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: MessageWidget(
                    isUser: message["isUser"],
                    messageText: message["messageText"],
                    profilePicUrl: message["profilePicUrl"],
                    timestamp: message["timestamp"],
                  ),
                );
              },
              controller: _scrollController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Écrire un message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
