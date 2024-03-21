import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/widgets/sub_widgets/text_widget.dart';

class MessageWidget extends StatelessWidget {
  final bool isUser;
  final String messageText;
  final String profilePicUrl;
  final String timestamp;

  const MessageWidget({
    Key? key,
    required this.isUser,
    required this.messageText,
    required this.profilePicUrl,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Color textColor = isUser ? Colors.lightBlue : Colors.indigo;

    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isUser)
          CircleAvatar(
            backgroundImage: NetworkImage(profilePicUrl),
          ),
        Padding(
          padding: const EdgeInsets.all(7.0),
          // Text Widget
          child: TextWidget(text: messageText, color: textColor),
        ),
        if (!isUser)
          CircleAvatar(
            backgroundImage: NetworkImage(profilePicUrl),
          ),
      ],
    );
  }
}
