import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/widgets/message_widget.dart';

class Conversation extends StatefulWidget {
  const Conversation({super.key});

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Map<String, dynamic>> messages = [
    {
      "isUser": false,
      "messageText": "Bonjour !",
      "profilePicUrl": "https://example.com/image1.jpg",
      "timestamp": "10:45 AM",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AnimatedList(
          key: _listKey,
          initialItemCount: messages.length,
          itemBuilder: (context, index, animation) {
            final message = messages[index];
            return SlideTransition(
              position: Tween<Offset>(
                begin: message["isUser"] ? Offset(1, 0) : Offset(-1, 0),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              List<String> sampleMessages = [
                "Ceci est un message court.",
                "Ceci est un message de taille moyenne, contenant un peu plus de contenu et de détails.",
                "Ceci est un message assez long, conçu pour tester comment l'application gère les messages qui contiennent beaucoup de texte. Il est utile pour voir comment le widget de message s'adapte pour accommoder un grand volume de texte sans déborder ou causer des problèmes de mise en page.",
              ];

              String selectedMessage =
                  sampleMessages[Random().nextInt(sampleMessages.length)];
              bool user = Random().nextBool();

              final int index = messages.length;
              messages.add({
                "isUser": user,
                "messageText": selectedMessage,
                "profilePicUrl": user
                    ? "https://img-19.commentcamarche.net/WNCe54PoGxObY8PCXUxMGQ0Gwss=/480x270/smart/d8c10e7fd21a485c909a5b4c5d99e611/ccmcms-commentcamarche/20456790.jpg"
                    : "https://pixlr.com/images/index/ai-image-generator-three.webp",
                "timestamp": DateFormat('hh:mm a').format(DateTime.now()),
              });

              _listKey.currentState?.insertItem(index);
            });
            Future<void>.delayed(Duration(milliseconds: 100), () {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              }
            });
          },
          tooltip: 'Ajouter Message',
          child: const Icon(Icons.add),
        ));
  }
}
