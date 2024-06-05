import 'dart:async';
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
  String currentUserName = '';
  bool _isScrollButtonVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _initialize();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  Future<void> _initialize() async {
    await _loadChannel();
    if (channelId != null) {
      await _loadMessages();
      await _loadCurrentUserName();
      _subscribeToNewMessages();
    }
  }

  Future<void> _loadChannel() async {
    final userId = await _appwriteService.getCurrentUserId();
    channelId = await _appwriteService.getChannelIdByName(userId, widget.channelName);
  }

  Future<void> _loadMessages() async {
    if (channelId == null) return;
    final messagesFromDB = await _appwriteService.getMessagesByChannelId(channelId!);

    for (int i = 0; i < messagesFromDB.length; i++) {
      final message = messagesFromDB[i];

      final String userId = message['ID_Users'] as String? ?? '';
      final String messageText = message['messageText'] as String? ?? '';
      final String timestamp = message['timestamp'] as String? ?? '';
      if (userId.isEmpty || messageText.isEmpty || timestamp.isEmpty) {
        print('Skipping message due to missing required fields.');
        continue;
      }

      final sender = await _appwriteService.getUserByID(userId);
      final String backgroundColor = sender.data['backgroundColor'] as String? ?? 'blue';
      final String userName = sender.data['Nom'] as String? ?? 'Unknown';
      final String profilePicUrl = sender.data['URL_PP'] as String? ?? 'https://static.vecteezy.com/system/resources/thumbnails/020/765/399/small/default-profile-account-unknown-icon-black-silhouette-free-vector.jpg';

      message['backgroundColor'] = backgroundColor;
      message['userName'] = userName;
      message['profilePicUrl'] = profilePicUrl;

      bool showInfo = true;
      if (i > 0) {
        final prevMessage = messagesFromDB[i - 1];
        final String prevUserId = prevMessage['ID_Users'] as String? ?? '';
        final DateTime prevTimestamp = DateTime.parse(prevMessage['timestamp'] as String? ?? '');
        final DateTime currentTimestamp = DateTime.parse(timestamp);

        if (userId == prevUserId && currentTimestamp.difference(prevTimestamp).inMinutes < 10) {
          showInfo = false;
        }
      }

      message['showInfo'] = showInfo;
      messages.add(message);
      _listKey.currentState?.insertItem(messages.length - 1);
    }
    _scrollToBottom();
  }

  Future<void> _loadCurrentUserName() async {
    currentUserName = await _appwriteService.getCurrentUserName();
  }

  void _subscribeToNewMessages() {
    _appwriteService.subscribeToMessages((newMessage) async {
      if (newMessage.payload['ChannelID'] == channelId) {
        final userId = await _appwriteService.getCurrentUserId();
        final sender = await _appwriteService.getUserByID(newMessage.payload['ID_Users']);
        final isUser = newMessage.payload['ID_Users'].contains(userId);
        final messageText = newMessage.payload['Contenue'] ?? '';
        final timestamp = newMessage.payload['Date_Heure'] ?? '';
        final profilePicUrl = await _appwriteService.getUserPP(newMessage.payload['ID_Users']) ?? 'https://static.vecteezy.com/system/resources/thumbnails/020/765/399/small/default-profile-account-unknown-icon-black-silhouette-free-vector.jpg';
        final backgroundColor = sender.data['backgroundColor'] ?? '#000000';
        final userName = sender.data['Nom'];

        final newMessageMap = {
          'isUser': isUser,
          'messageText': messageText,
          'profilePicUrl': profilePicUrl,
          'timestamp': timestamp,
          'backgroundColor': backgroundColor,
          'userName': userName,
          'showInfo': true,
        };

        if (messages.isNotEmpty) {
          final lastMessage = messages.last;
          final lastUserID = await _appwriteService.getUserIdByUsername(lastMessage['userName']);
          final lastTimestamp = DateTime.parse(lastMessage['timestamp']);
          final currentTimestamp = DateTime.parse(timestamp);

          if (newMessage.payload['ID_Users'] == lastUserID &&
              currentTimestamp.difference(lastTimestamp).inMinutes < 10) {
            newMessageMap['showInfo'] = false;
          }
        }

        setState(() {
          messages.add(newMessageMap);
          _listKey.currentState?.insertItem(messages.length - 1);
        });

        _scrollToBottom();
      }
    });
  }

  Future<void> _addUserToChannel(String username) async {
    try {
      if (channelId == null) return;
      final userId = await _appwriteService.getUserIdByUsername(username);
      await _appwriteService.addUserChannel(userId, channelId!);
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
      final messageCount = await _appwriteService.getMaxMessageId();
      final messageId = messageCount + 1;

      await _appwriteService.createMessage(
        messageId,
        userId,
        timestamp,
        _messageController.text,
        channelId!,
      );

      _messageController.clear();
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

  Future<void> _showUsers() async {
    if (channelId == null) return;

    final channelDetails = await _appwriteService.getChannelById(channelId!);
    List<dynamic> users = channelDetails['UsersID'];
    List<String> userNames = [];

    for (var userId in users) {
      final user = await _appwriteService.getUserByID(userId);
      userNames.add(user.data['Nom']);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Participants'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: userNames.map((userName) {
              return Text(
                userName,
                style: TextStyle(
                  fontWeight: userName == currentUserName ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      bool isScrolledToBottom = _scrollController.position.pixels >= _scrollController.position.maxScrollExtent;
      setState(() {
        _isScrollButtonVisible = !isScrolledToBottom;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.channelName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddUserDialog,
          ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: _showUsers,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: AnimatedList(
                  key: _listKey,
                  initialItemCount: messages.length,
                  itemBuilder: (context, index, animation) {
                    final message = messages[index];
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: message["isUser"] ? const Offset(-1, 0) : const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: MessageWidget(
                          isUser: message["isUser"],
                          messageText: message["messageText"],
                          profilePicUrl: message["profilePicUrl"] is String ? message["profilePicUrl"] : "",
                          timestamp: message["timestamp"],
                          backgroundColor: message["backgroundColor"],
                          userName: message["userName"],
                          showInfo: message["showInfo"],
                        ),
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
                        onSubmitted: (value) => _sendMessage(),
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
          if (_isScrollButtonVisible)
            Positioned(
              bottom: 80,
              right: 20,
              child: Opacity(
                opacity: 0.5,
                child: FloatingActionButton(
                  onPressed: _scrollToBottom,
                  child: const Icon(Icons.arrow_downward),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
