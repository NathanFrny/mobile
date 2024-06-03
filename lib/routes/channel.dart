import 'package:flutter/material.dart';
import 'conversation.dart';

class Channel extends StatefulWidget {
  const Channel({super.key});

  @override
  State<Channel> createState() => _ChannelState();
}

class _ChannelState extends State<Channel> {
  final List<Map<String, dynamic>> channels = [
    {"name": "General", "id": 1},
    {"name": "Flutter", "id": 2},
  ];

  void _navigateToConversation(BuildContext context, String channelName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Conversation(channelName: channelName),
      ),
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
          return ListTile(
            title: Text(channels[index]['name']),
            onTap: () => _navigateToConversation(context, channels[index]['name']),
          );
        },
      ),
    );
  }
}
