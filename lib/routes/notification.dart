import 'package:flutter/material.dart';
import 'package:mobile/services/appwrite_service.dart';

class NotificationsPage extends StatelessWidget {
  final Map<int, int> unreadMessages;
  final List<Map<String, dynamic>> channels;
  final Function(int) onChannelTap;
  final AppwriteService appwriteService;

  const NotificationsPage({
    super.key,
    required this.unreadMessages,
    required this.channels,
    required this.onChannelTap,
    required this.appwriteService,
  });

  Future<List<String>> _getUserProfilePics(List<String> userIds) async {
    List<String> profilePics = [];
    for (String userId in userIds) {
      String profilePicUrl = await appwriteService.getUserPP(userId);
      profilePics.add(profilePicUrl);
    }
    return profilePics;
  }

  @override
  Widget build(BuildContext context) {
    final validNotifications =
        unreadMessages.entries.where((entry) => entry.value > 0).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appwriteService.confirmLogout(context),
        ),
      ),
      body: ListView.builder(
        itemCount: validNotifications.length,
        itemBuilder: (context, index) {
          final channelId = validNotifications[index].key;
          final unreadCount = validNotifications[index].value;
          final channel = channels.firstWhere(
            (channel) => int.parse(channel['id']) == channelId,
            orElse: () => <String, dynamic>{},
          );

          if (channel.isEmpty) {
            return const SizedBox(); // or any other placeholder
          }

          final channelName = channel['name'];
          final userIds = channel['UsersID'].cast<String>();

          return FutureBuilder<List<String>>(
            future: _getUserProfilePics(userIds),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              final profilePics = snapshot.data!;
              return Card(
                child: ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (profilePics.isNotEmpty)
                        CircleAvatar(
                          backgroundImage: NetworkImage(profilePics[0]),
                        ),
                      if (profilePics.length > 1)
                        CircleAvatar(
                          backgroundImage: NetworkImage(profilePics[1]),
                        ),
                      if (profilePics.length > 2)
                        const CircleAvatar(
                          child: Text('...'),
                        ),
                    ],
                  ),
                  title: Text(channelName),
                  subtitle: Text('$unreadCount nouveaux messages'),
                  onTap: () => onChannelTap(channelId),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
