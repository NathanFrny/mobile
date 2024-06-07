# CSend

**CSend** est une application mobile de **messagerie** **en temps réel**. Cette dernière propose à ses utilisateurs de **créer des channels**, d'y **inviter** 1 ou **plusieurs** amis et d'y discuter en temps réel.

<p align="center">
  <a href="#test">Comment tester l'application ?</a> •
  <a href="#feat">Features de l'application</a> •
  <a href="#technique">Parties technique</a> •
  <a href="#credit">Crédits</a> •
  <a href="#license">License</a>
</p>

## Participants

- Nathan Fourny
- Thimoté Bois
- Florient Artu
- Colin Prokopowicz
- Bonnel Noah

<div id="test"></div>

## Comment tester l'application ?


Téléchargez la dernière [release](https://github.com/NathanFrny/mobile/releases) de l'application (CSend - v1.3.0).  
Créez un compte et connectez-vous à ce dernier.

**Remarque: Pour des tests approfondis il est recommandé de créer au moins 2 comptes et d'alterner entre ces derniers.**

<div id="feat"></div>

## Features de l'Application


###  Page d'accueil

La page d'**accueil** met en avant le logo  
On retrouve :
- bouton de **connexion**
- bouton d'*inscription*

### Connexion / Inscription

Dans la page d'inscription, il est possible d'**afficher** son mot de passe et il faut le **confirmer** pour s'inscrire.  
Les mots de passes sont **chiffrés** dans la base de données.

Pour la connexion, il suffit de rentrer son email et son mot de passe.

**Remarque: Les sessions sont sauvegardés, une fois connectés l'utilisateur n'aura pas à le refaire tant qu'il ne se déconnecte pas lui même.**

### Naviguation

La navigation est un widget utilisé permettant de **naviguer** entre les 3 onglets principaux une fois connectés : "**Home**", "**Notifications**" et "**Channels**".

Lorsqu'on reçoit des notifications, des **icônes** **apparaissent** sur l'onglet "Notifications" ainsi que "channels" pour indiquer le **nombre** de notifications reçues.

### Home

La page "Home" est la page **profil** de l'utilisateur.  
On y retrouve la **photo de profil** de l'utilisateur ainsi que son **pseudo**.  
On peut **modifier** les deux informations en cliquant/appuyant dessus.

De plus, nous avons ajouté la possibilités de **modifier** la **couleur** **d'arrière-plan des messages** de l'utilisateur.  
Nous offrons le choix entre huit couleur, il suffit d'appuyer pour changer de couleur.

### Notifications

La page "Notifications" est la page où l'utilisateur peut voir les **notifications** reçues.

**Remarque: Les notifications ne fonctionnent que lorsque l'utilisateur est connecté à l'application !**

Ces dernières afficheront les **photos de profils des utilisateurs** qui ont envoyés un messages, le **nom du channel** ainsi que le **nombre de messages non lues**.  
**Cliquer** sur la notification permet de se rendre sur l'onglet channel.

**Se rendre** dans le channel concerné supprime les messages non lues.  
La notification disparait **lorsqu'il n'y a plus de messages non lues**.

### Channels

La page "Channels" est la page où l'utilisateur peut voir les **différents channels** auxquels il est affilié.

Pour **créer** **un** **channel** il suffit de cliquer sur le bouton "+" en bas à droite de l'écran.  
Les channels sont affichés sous forme de liste, avec le **nom du channel** en question.

à droit des "card" de channel, on retrouve un **bouton rouge "-"** permettant à l'utilisateur de **quitter** un channel.  
Lorsqu'un channel ne possède plus d'utilisateur, il est **automatiquement supprimé** ainsi que **tous les messages** qu'il contient dans la base de données.

### Channel

La page de channel est la page où l'utilisateur peut voir les **messages** envoyés dans le channel.  
On retrouve un **champ de texte** en bas de l'écran pour envoyer un message.  
On retrouve en haut le nom du channel, ainsi que 2 icônes.

- La première icône permet d'**ajouter** un participant au channel
- La seconde icône permet de **visualiser** la liste des participants

L'envoi des messages se fait en **temps réel**.

Les messages possèdent les features suivantes :

- **Affichage de la photo de profil de l'utilisateur**, son **pseudo** ainsi que la **date et l'heure d'envoi**.  
  Lorsqu'un utilisateur envoi **plusieurs messages simultanément**, on ne réaffiche **pas** les informations, **seulement** le texte.  
  Les informations sont réaffichées lorsqu'un autre utilisateur **envoi un message** ou que le dernier message date de plus de **10 minutes**.


<div id="technique"> </div>

## Parties techniques


Tout le développement mobile a été réalisé avec **flutter**.  
Pour la partie backend, nous avons utilisé **Appwrite**. Nous avons hébergé le service **localement** sur un Raspberry PI.

Pour réaliser l'envoi des messages, nous avons utilisés une **realtime database** avec appwrite. L'utilisateurs s'"**abonne**" à la table "messages" dans la base de données, dès lors qu'un message en envoyé,  
ce dernier est **notifié** et peut afficher le message en **temps réel** dans son channel.  
Le fonctionnement est similaire pour les notifications.
De plus, pour éviter de charger trop de messages, lorsqu'on arrive sur un channel on ne charge que les 20 derniers messages.  
Lorsqu'on rescroll vers le haut, on charge les messages précédents ainsi de suite.  
Un bouton permet de rapidement retourner tout en bas de la conversations.

Des maquettes sur **figma** on préalablement était réalisées pour avoir une idée de l'application.

L'application a été découpé en plusieurs **versions** lors des releases, chacune offrant des nouvelles fonctionnalités ainsi que des corrections de bugs.

<div id="credit"> </div>

## Crédits


- [Flutter](https://flutter.dev/)
- [Appwrite](https://appwrite.io/)

<div id="license"></div>

## License


All right reserved.

