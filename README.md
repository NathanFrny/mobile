# mobile


## Documentation
### Comment ajouter un message ?

Exemple de création d'un message :  

```dart
const MessageWidget(
  isUser: false,
  messageText: "Ceci est un message",
  profilePicUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTgbmG8Ebh27B3t5ChGhk7EWbZ6j2YRPX5IMA&usqp=CAU',
  timestamp: '10:50 AM',
),
```

Paramètre possible dans un message :  
isUser = Si c'est l'utilisateur le message s'affichera à gauche en bleu clair sinon à droite en indigo.  
messageText = Le contenu du message.  
profilePicUrl = l'URL en ligne de la photo de profil de l'utilisateur.  
timestamp = L'heure à laquelle le message a été envoyé.  