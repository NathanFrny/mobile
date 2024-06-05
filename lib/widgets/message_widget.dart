import 'package:flutter/material.dart';
import 'package:mobile/widgets/sub_widgets/text_widget.dart';
import 'package:intl/intl.dart';

class MessageWidget extends StatelessWidget {
  final bool isUser;
  final String messageText;
  final String profilePicUrl;
  final String timestamp;
  final String backgroundColor;
  final String userName;
  final bool showInfo;

  const MessageWidget({
    super.key,
    required this.isUser,
    required this.messageText,
    required this.profilePicUrl,
    required this.timestamp,
    required this.backgroundColor,
    required this.userName,
    required this.showInfo,
  });

  String _formatTimestamp(String timestamp) {
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
      String formattedTime = DateFormat('HH:mm').format(dateTime);
      return '$formattedDate $formattedTime';
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedTimestamp = _formatTimestamp(timestamp);
    final Color bgColor = _getColorFromName(backgroundColor);

    return Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (showInfo) ...[
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser)
                CircleAvatar(
                  backgroundImage: NetworkImage(profilePicUrl),
                ),
              if (!isUser) const SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedTimestamp,
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  TextWidget(text: messageText, color: bgColor),
                ],
              ),
              if (isUser) const SizedBox(width: 8.0),
              if (isUser)
                CircleAvatar(
                  backgroundImage: NetworkImage(profilePicUrl),
                ),
            ],
          ),
        ] else ...[
          Padding(
            padding: EdgeInsets.only(
              left: isUser ? 0 : 48.0, // Espace réservé pour l'avatar si ce n'est pas l'utilisateur
              right: isUser ? 48.0 : 0, // Espace réservé pour l'avatar si c'est l'utilisateur
              top: 2.0,
              bottom: 2.0,
            ),
            child: Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: TextWidget(text: messageText, color: bgColor),
            ),
          ),
        ],
      ],
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.yellow;
      case 'red':
        return Colors.red;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'black':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }
}
