import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';

class AppwriteService {
  late Client _client;
  late Account _account;
  late Databases _databases;
  final endPoint = 'https://appwrite.thimotebois.ovh/v1';
  final projetID = '66178c2b1086e66b625a';
  final databaseID = '664a2388d737af1394f7';
  final collectionUsersID = '664a2399f0515c0a2afb';
  final collectionMessagesID = '664a23a4df74b3057cef';
  final collectionChannelsID = '664a23ae6c741e56b1a7';

  AppwriteService() {
    _client = Client().setEndpoint(endPoint).setProject(projetID);
    _account = Account(_client);
    _databases = Databases(_client);
  }

  // ---------------------------
  //  Gestion des utilisateurs
  // ---------------------------

  // Création d'un utilisateur et enregistrement dans la base de données Users
  // Param :
  // - email : email de l'utilisateur
  // - password : mot de passe de l'utilisateur
  // - name : nom de l'utilisateur
  Future<void> registerUser(String email, String password, String name) async {
    try {
      final user = await _account.create(
        userId: 'unique()',
        email: email,
        password: password,
        name: name,
      );

      await _databases.createDocument(
        databaseId: databaseID,
        collectionId: collectionUsersID,
        documentId: user.$id,
        data: {
          'ID': user.$id,
          'Nom': name,
          'Date_creation': DateTime.now().toIso8601String(),
          'Channel': [],
        },
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription : $e');
    }
  }

  // Connexion d'un utilisateur
  // Param :
  // - email : email de l'utilisateur
  // - password : mot de passe de l'utilisateur
  Future<void> loginUser(String email, String password) async {
    try {
      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Erreur lors de la connexion : $e');
    }
  }

  // Suppression de la session actuelle
  Future<void> deleteSession() async {
    if (kDebugMode) {
      print("Suppression de la session");
    }
    try {
      try {
        await _account.getSession(sessionId: 'current');
      } on AppwriteException catch (e) {
        if (e.code == 401) {
          return;
        } else {
          throw Exception(
              'Erreur lors de la vérification de la session : ${e.message}');
        }
      }
      try {
        await _account.deleteSession(sessionId: 'current');
      } on AppwriteException catch (e) {
        throw Exception(
            'Erreur lors de la suppression de la session : ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur générale : $e');
    }
  }

  // ---------------------------
  //  Gestion des Utilisateurs
  // ---------------------------

  // Récupération des informations d'un utilisateur par son ID dans la base de données Users
  // Param :
  // - userId : ID de l'utilisateur
  //
  // Return : Document de l'utilisateur
  //
  // Exemple d'utilisation :'
  // final user = await _appwriteService.getUserByID(userId);
  // print(user.data['Nom']);
  Future<models.Document> getUserByID(String userId) async {
    try {
      return await _databases.getDocument(
        databaseId: databaseID,
        collectionId: collectionUsersID,
        documentId: userId,
      );
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération des informations utilisateur : $e');
    }
  }

  // Récupération du nom de l'utilisateur actuellement connecté
  //
  // Return : Nom de l'utilisateur
  Future<String> getCurrentUserName() async {
    try {
      final user = await _account.get();
      return user.name;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du nom utilisateur : $e');
    }
  }

  // Récupération de l'ID de l'utilisateur actuellement connecté
  //
  // Return : ID de l'utilisateur
  Future<String> getCurrentUserId() async {
    try {
      final user = await _account.get();
      return user.$id;
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération de l\'ID utilisateur : $e');
    }
  }

  // Récupération de la Date de création d'un utilisateur dans la base de données Users
  //
  // Return : Date de création de l'utilisateur formatée en String au format 'JJ/MM/AAAA - HH:MM:SS'
  Future<String> getCurrentUserCreationDate(String userID) async {
    try {
      final userDocument = await getUserByID(userID);
      final dateCreation = userDocument.data['Date_creation'];
      final dateCreationFormatted = DateTime.parse(dateCreation);
      return dateCreationFormatted.toString();
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération de la date de création de l\'utilisateur : $e');
    }
  }

  // Récupération des channels d'un utilisateur dans la base de données Users
  //
  // Return : Liste des channels de l'utilisateur
  Future<List<dynamic>> getUserChannels(String userID) async {
    try {
      final userDocument = await getUserByID(userID);
      return userDocument.data['Channel'];
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération des channels de l\'utilisateur : $e');
    }
  }

  // Récupération de la PP d'un utilisateur dans la base de données Users
  //
  // Return : URL de la PP de l'utilisateur
  Future<String> getUserPP(String userID) async {
    try {
      final userDocument = await getUserByID(userID);
      return userDocument.data['PP'];
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération de la PP de l\'utilisateur : $e');
    }
  }

  // Modification de la PP d'un utilisateur dans la base de données Users
  // Param :
  // - userID : ID de l'utilisateur
  // - pp : URL de la PP
  Future<void> setUserPP(String userID, String pp) async {
    try {
      await _databases.updateDocument(
        databaseId: databaseID,
        collectionId: collectionUsersID,
        documentId: userID,
        data: {
          'URL_PP': pp,
        },
      );
    } catch (e) {
      throw Exception(
          'Erreur lors de la modification de la PP de l\'utilisateur : $e');
    }
  }

  // Ajouts d'un channel à la liste des channels d'un utilisateur dans la base de données Users
  // Param :
  // - userID : ID de l'utilisateur
  // - channelID : ID du channel
  Future<void> addUserChannel(String userID, int channelID) async {
    try {
      final userDocument = await getUserByID(userID);
      final channels = userDocument.data['Channel'];
      channels.add(channelID);

      await _databases.updateDocument(
        databaseId: databaseID,
        collectionId: collectionUsersID,
        documentId: userID,
        data: {
          'Channel': channels,
        },
      );
    } catch (e) {
      throw Exception(
          'Erreur lors de l\'ajout du channel à la liste des channels de l\'utilisateur : $e');
    }
  }

  // Suppression d'un channel de la liste des channels d'un utilisateur dans la base de données Users
  // Param :
  // - userID : ID de l'utilisateur
  // - channelID : ID du channel
  Future<void> removeUserChannel(String userID, int channelID) async {
    try {
      final userDocument = await getUserByID(userID);
      final channels = userDocument.data['Channel'];
      channels.remove(channelID);

      await _databases.updateDocument(
        databaseId: databaseID,
        collectionId: collectionUsersID,
        documentId: userID,
        data: {
          'Channel': channels,
        },
      );
    } catch (e) {
      throw Exception(
          'Erreur lors de la suppression du channel de la liste des channels de l\'utilisateur : $e');
    }
  }

// ---------------------------
//  Gestion des messages
// ---------------------------

// Création d'un message et enregistrement dans la base de données Messages
// Param :
// - messageID : ID du message
// - UserID : ID de l'utilisateur
// - DateHeure : Date et heure du message
// - Contenu : Contenu du message
// - ChannelID : ID du channel
  Future<void> createMessage(String messageID, String userID, String dateHeure,
      String contenu, int channelID) async {
    try {
      await _databases.createDocument(
        databaseId: databaseID,
        collectionId: collectionMessagesID,
        documentId: messageID,
        data: {
          'ID': messageID,
          'UserID': userID,
          'DateHeure': dateHeure,
          'Contenu': contenu,
          'ChannelID': channelID,
        },
      );
    } catch (e) {
      throw Exception('Erreur lors de la création du message : $e');
    }
  }

//---------------------------
//  Gestion des channels
// ---------------------------

  // Création d'un channel et enregistrement dans la base de données Channels
  // Param :
  // - channelID : ID du channel
  // - channelNom : Nom du channel
  Future<void> createChannel(int channelID, String channelNom) async {
    try {
      await _databases.createDocument(
        databaseId: databaseID,
        collectionId: collectionChannelsID,
        documentId: channelID.toString(),
        data: {
          'ID': channelID,
          'Nom': channelNom,
        },
      );
    } catch (e) {
      throw Exception('Erreur lors de la création du channel : $e');
    }
  }

  // Récupère le nombre total de channel
  Future<int> getChannelCount() async {
    try {
      final response = await _databases.listDocuments(
        databaseId: databaseID,
        collectionId: collectionChannelsID,
      );
      return response.total;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du nombre total de channels : $e');
    }
  }

  // Récupérer un channel en fonction de son ID
  // Param :
  // - channelID: ID du channel
  Future<Map<String, dynamic>> getChannelById(int channelId) async {
    try {
      final document = await _databases.getDocument(
        databaseId: databaseID,
        collectionId: collectionChannelsID,
        documentId: channelId.toString(),
      );
      return {
        'id': document.$id,
        'name': document.data['Nom'],
      };
    } catch (e) {
      throw Exception('Erreur lors de la récupération du channel : $e');
    }
  }

  // Ajout d'un utilisateur à un channel dans la base de données Channels
  // Param :
  // - userID : ID de l'utilisateur
  // - channelID : ID du channel
  Future<void> addUserToChannel(String userID, int channelID) async {
    try {
      final channelDocument = await _databases.getDocument(
        databaseId: databaseID,
        collectionId: collectionChannelsID,
        documentId: channelID.toString(),
      );
      final users = channelDocument.data['UsersID'];
      users.add(userID);

      await _databases.updateDocument(
        databaseId: databaseID,
        collectionId: collectionChannelsID,
        documentId: channelID.toString(),
        data: {
          'UsersID': users,
        },
      );
    } catch (e) {
      throw Exception(
          'Erreur lors de l\'ajout de l\'utilisateur au channel : $e');
    }
  }

  // Suppression d'un utilisateur d'un channel dans la base de données Channels
  // Param :
  // - userID : ID de l'utilisateur
  // - channelID : ID du channel
  Future<void> removeUserFromChannel(String userID, int channelID) async {
    try {
      final channelDocument = await _databases.getDocument(
        databaseId: databaseID,
        collectionId: collectionChannelsID,
        documentId: channelID.toString(),
      );
      final users = channelDocument.data['UsersID'];
      users.remove(userID);

      await _databases.updateDocument(
        databaseId: databaseID,
        collectionId: collectionChannelsID,
        documentId: channelID.toString(),
        data: {
          'UsersID': users,
        },
      );
    } catch (e) {
      throw Exception(
          'Erreur lors de la suppression de l\'utilisateur du channel : $e');
    }
  }

  // Changement du nom d'un channel dans la base de données Channels
  // Param :
  // - channelID : ID du channel
  // - channelNom : Nouveau nom du channel
  Future<void> changeChannelName(int channelID, String channelNom) async {
    try {
      await _databases.updateDocument(
        databaseId: databaseID,
        collectionId: collectionChannelsID,
        documentId: channelID.toString(),
        data: {
          'Nom': channelNom,
        },
      );
    } catch (e) {
      throw Exception('Erreur lors du changement du nom du channel : $e');
    }
  }

  // Change de la PP d'un channel dans la base de données Channels
  // Param :
  // - channelID : ID du channel
  // - pp : URL de la PP
  Future<void> setChannelPP(int channelID, String pp) async {
    try {
      await _databases.updateDocument(
        databaseId: databaseID,
        collectionId: collectionChannelsID,
        documentId: channelID.toString(),
        data: {
          'URL_PP': pp,
        },
      );
    } catch (e) {
      throw Exception(
          'Erreur lors de la modification de la PP du channel : $e');
    }
  }
}
