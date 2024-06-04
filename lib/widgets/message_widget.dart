import 'package:flutter/material.dart';
import 'package:mobile/widgets/sub_widgets/text_widget.dart';
import 'package:intl/intl.dart';

class MessageWidget extends StatelessWidget {
  final bool isUser;
  final String messageText;
  final String profilePicUrl;
  final String timestamp;

  const MessageWidget({
    super.key,
    required this.isUser,
    required this.messageText,
    required this.profilePicUrl,
    required this.timestamp,
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

    Color textColor = isUser ? Colors.lightBlue : Colors.indigo;
    String formattedTimestamp = _formatTimestamp(timestamp);

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
        Padding(
          padding: const EdgeInsets.all(7.0),
          // Text Widget
          child: TextWidget(text: messageText, color: textColor),
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
}
