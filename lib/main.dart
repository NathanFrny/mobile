import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/widgets/message_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return MessageWidget(
            isUser: message["isUser"],
            messageText: message["messageText"],
            profilePicUrl: message["profilePicUrl"],
            timestamp: message["timestamp"],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            List<String> sampleMessages = [
              "Ceci est un message court.",
              "Ceci est un message de taille moyenne, contenant un peu plus de contenu et de détails.",
              "Ceci est un message assez long, conçu pour tester comment l'application gère les messages qui contiennent beaucoup de texte. Il est utile pour voir comment le widget de message s'adapte pour accommoder un grand volume de texte sans déborder ou causer des problèmes de mise en page.",
            ];

            String selectedMessage = sampleMessages[Random().nextInt(sampleMessages.length)];
            bool user = Random().nextBool();

            messages.add({
              "isUser": user,
              "messageText": selectedMessage,
              "profilePicUrl": user ? "https://pixlr.com/images/index/ai-image-generator-three.webp" : "https://img-19.commentcamarche.net/WNCe54PoGxObY8PCXUxMGQ0Gwss=/480x270/smart/d8c10e7fd21a485c909a5b4c5d99e611/ccmcms-commentcamarche/20456790.jpg",
              "timestamp": DateFormat('hh:mm a').format(DateTime.now()),
            });
          });
        },
        tooltip: 'Ajouter Message',
        child: const Icon(Icons.add),
      )
    );
  }
}
