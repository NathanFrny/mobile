import 'package:flutter/material.dart';
import 'package:mobile/widgets/sub_widgets/text_widget.dart';
import 'package:intl/intl.dart';

class MessageWidget extends StatelessWidget {
  final bool isUser;
  final String messageText;
  final String profilePicUrl;
  final String timestamp;
  final String backgroundColor;

  const MessageWidget({
    super.key,
    required this.isUser,
    required this.messageText,
    required this.profilePicUrl,
    required this.timestamp,
    required this.backgroundColor,
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

    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser)
          CircleAvatar(
            backgroundImage: NetworkImage(profilePicUrl),
          ),
        if (isUser)
          Text(
            formattedTimestamp,
            style: const TextStyle(
              fontSize: 10,
            ),
          ),
        Container(
          child: TextWidget(text: messageText, color: bgColor),
        ),
        if (isUser)
          CircleAvatar(
            backgroundImage: NetworkImage(profilePicUrl),
          ),
        if (!isUser)
          Text(
            formattedTimestamp,
            style: const TextStyle(
              fontSize: 10,
            ),
          ),
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