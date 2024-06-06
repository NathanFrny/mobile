import 'package:flutter/material.dart';
import 'package:mobile/routes/channel.dart';
import 'package:mobile/routes/home.dart';
import 'package:mobile/routes/notification.dart';
import 'package:mobile/routes/channel.dart' as channel;
import 'package:mobile/routes/notification.dart' as notification;
import 'package:mobile/services/appwrite_service.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int currentPageIndex = 0;
  final AppwriteService _appwriteService = AppwriteService();
  ValueNotifier<Map<int, int>> unreadMessages = ValueNotifier({});
  List<Map<String, dynamic>> channels = [];

  @override
  void initState() {
    super.initState();
    _loadChannels();
    _subscribeToMessages();
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

  void _subscribeToMessages() {
    _appwriteService.subscribeToMessages((newMessage) {
      try {
        final channelId = newMessage.payload['ChannelID'] is int
            ? newMessage.payload['ChannelID']
            : int.parse(newMessage.payload['ChannelID']);
        unreadMessages.value = {
          ...unreadMessages.value,
          channelId: (unreadMessages.value[channelId] ?? 0) + 1,
        };
      } catch (e) {
        print('Erreur lors du traitement du message : $e');
      }
    });
  }

  void _onChannelTap(int channelId) {
    unreadMessages.value = {
      ...unreadMessages.value,
      channelId: 0,
    };
    unreadMessages.notifyListeners(); // Notify listeners explicitly
    setState(() {
      currentPageIndex = 2; // Switch to the channel page
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: unreadMessages,
        builder: (context, Map<int, int> value, child) {
          int totalUnreadMessages =
              value.values.fold(0, (sum, count) => sum + count);
          return NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            indicatorColor: theme.colorScheme.primary,
            selectedIndex: currentPageIndex,
            destinations: <Widget>[
              NavigationDestination(
                selectedIcon: Icon(Icons.home),
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Badge(
                  label: totalUnreadMessages > 0
                      ? Text(totalUnreadMessages.toString())
                      : null,
                  child: Icon(Icons.notifications_sharp),
                ),
                label: 'Notifications',
              ),
              NavigationDestination(
                icon: Badge(
                  label: totalUnreadMessages > 0
                      ? Text(totalUnreadMessages.toString())
                      : null,
                  child: Icon(Icons.messenger_sharp),
                ),
                label: 'Channels',
              ),
            ],
          );
        },
      ),
      body: <Widget>[
        const Home(),
        notification.NotificationsPage(
          unreadMessages: unreadMessages.value,
          channels: channels,
          onChannelTap: _onChannelTap,
          appwriteService: _appwriteService,
        ),
        // ...

        channel.Channel(unreadMessages: unreadMessages),
      ][currentPageIndex],
    );
  }
}
