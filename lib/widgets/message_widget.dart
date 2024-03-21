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
    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser)
          CircleAvatar(
            backgroundImage: NetworkImage(profilePicUrl),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextWidget(text: messageText), // Utilisation de TextWidget ici
        ),
        if (isUser)
          CircleAvatar(
            backgroundImage: NetworkImage(profilePicUrl),
          ),
        // Vous pouvez ajouter plus de widgets ici, comme l'heure d'envoi
      ],
    );
  }
}
