import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';

class AppwriteService {
  late Client _client;
  late Account _account;
  late Databases _databases;
  late Realtime _realtime;
  final endPoint = 'https://appwrite.thimotebois.ovh/v1';
  final projetID = '66178c2b1086e66b625a';
  final databaseID = '664a2388d737af1394f7';
  final collectionUsersID = '664a2399f0515c0a2afb';
  final collectionMessagesID = '664a23a4df74b3057cef';
  final collectionChannelsID = '664a23ae6c741e56b1a7';

  AppwriteService() {
    _client = Client().setEndpoint(endPoint).setProject(projetID).setSelfSigned(status: true);
    _account = Account(_client);
    _databases = Databases(_client);
    _realtime = Realtime(_client);
  }

  // Abonnement en temps réel aux changements dans la collection de messages
  void subscribeToMessages(Function(RealtimeMessage) callback) {
    final subscription = _realtime.subscribe([
      'databases.$databaseID.collections.$collectionMessagesID.documents'
    ]);

    // Observer permettant à des callbacks de s'abonner
    subscription.stream.listen((event) {
      callback(event);
    }, onError: (error) {
      print('Erreur lors de la souscription en temps réel : $error');
    });
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
          'URL_PP': 'https://static.vecteezy.com/system/resources/thumbnails/020/765/399/small/default-profile-account-unknown-icon-black-silhouette-free-vector.jpg',
          'backgroundColor': 'blue',
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

  // Récupération de l'id d'un user en fonction de son pseudo
  // Params:
  // - username: pseudo du user
  Future<String> getUserIdByUsername(String username) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: databaseID,
        collectionId: collectionUsersID,
        queries: [
          Query.equal('Nom', username),
        ],
      );

      if (response.documents.isNotEmpty) {
        return response.documents.first.$id;
      } else {
        throw Exception('Utilisateur non trouvé');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'ID utilisateur : $e');
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

  // Récupère la couleur de fond de message d'un utilisateur
  // Params:
  // - userID: ID de l'utilisateur
  Future<String> getUserBackgroundColor(String userID) async {
    try {
      final userDocument = await getUserByID(userID);
      return userDocument.data['backgroundColor'];
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération de la couleur de fond de message de l\'utilisateur : $e');
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
      return userDocument.data['URL_PP'];
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

  // Met à jour la couleur de fond de message d'un utilisateur
  // Params:
  // - userId: ID de l'utilisateur
  // - color: Nouvelle couleur de fond
  Future<void> updateUserColor(String userId, String color) async {
    try {
      await _databases.updateDocument(
        databaseId: databaseID,
        collectionId: collectionUsersID,
        documentId: userId,
        data: {
          'backgroundColor': color,
        },
      );
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la couleur de fond de l\'utilisateur : $e');
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
  // - userID : ID de l'utilisateur
  // - dateHeure : Date et heure du message
  // - contenu : Contenu du message
  // - channelID : ID du channel
  Future<void> createMessage(int messageID, String userID, String dateHeure,
      String contenu, int channelID) async {
    try {

      await _databases.createDocument(
        databaseId: databaseID,
        collectionId: collectionMessagesID,
        documentId: messageID.toString(),
        data: {
          'ID': messageID,
          'Date_Heure': dateHeure,
          'Contenue': contenu,
          'ChannelID': channelID,
          'ID_Users': userID,
        },
      );
    } catch (e) {
      throw Exception('Erreur lors de la création du message : $e');
    }
  }

  // Récupérer les messages d'un channel en fonction de l'ID du channel
  // Params:
  // - channelId: l'id du channel
  Future<List<Map<String, dynamic>>> getMessagesByChannelId(int channelId) async {
    try {
      int limit = 100;
      final response = await _databases.listDocuments(
        databaseId: databaseID,
        collectionId: collectionMessagesID,
        queries: [
          Query.equal('ChannelID', channelId),
          Query.orderAsc('\$createdAt'),
          Query.limit(limit),
        ],
      );

      final currentUserId = await getCurrentUserId();
      final messageDetails = response.documents.map((doc) async {
        final isUser = doc.data['ID_Users'] == currentUserId;
        final messageText = doc.data['Contenue'];
        final timestamp = doc.data['Date_Heure'];
        return buildCompleteMessage(message: {
          'isUser': isUser,
          'messageText': messageText,
          'timestamp': timestamp,
          'ID_Users': doc.data['ID_Users'],
        }, userId: doc.data['ID_Users']);
      }).toList();

      // Wait for all message details to be retrieved
      final messages = await Future.wait(messageDetails);
      return messages;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des messages : $e');
    }
  }

  // This function should be defined elsewhere (assuming it builds the full message object with profile picture URL)
  Future<Map<String, dynamic>> buildCompleteMessage({required Map<String, dynamic> message, required String userId}) async {
    final profilePicUrl = await getUserPP(userId);
    return {
      ...message,
      'profilePicUrl': profilePicUrl,
    };
  }

  // Récupère le nombre total de messages dans un channel
  // Params:
  // - channelId: l'ID du channel
  Future<int> getMessageCountByChannel(int channelId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: databaseID,
        collectionId: collectionMessagesID,
        queries: [
          Query.equal('ChannelID', channelId),
        ],
      );
      return response.total;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du nombre total de messages pour le channel $channelId : $e');
    }
  }

  // Récupère le nombre total de messages
  Future<int> getMessageCount() async {
    try {
      final response = await _databases.listDocuments(
        databaseId: databaseID,
        collectionId: collectionMessagesID,
      );
      return response.total;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du nombre total de messages : $e');
    }
  }

  // Suppression de tous les messages associés à un channel
  // Params:
  // - channelId: ID du channel
  Future<void> deleteMessagesByChannelId(int channelId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: databaseID,
        collectionId: collectionMessagesID,
        queries: [
          Query.equal('ChannelID', channelId),
        ],
      );

      for (var document in response.documents) {
        await _databases.deleteDocument(
          databaseId: databaseID,
          collectionId: collectionMessagesID,
          documentId: document.$id,
        );
      }

      print('Tous les messages du channel $channelId ont été supprimés.');
    } catch (e) {
      throw Exception('Erreur lors de la suppression des messages du channel : $e');
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

  // Récupération de l'ID de channel le plus élevé
  Future<int> getMaxChannelId() async {
    try {
      final response = await _databases.listDocuments(
        databaseId: databaseID,
        collectionId: collectionChannelsID,
        queries: [
          Query.orderDesc('ID'),
          Query.limit(1),
        ],
      );

      if (response.documents.isNotEmpty) {
        return int.parse(response.documents.first.$id);
      } else {
        return 0;  // Retourner 0 si aucun channel n'existe
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'ID de channel le plus élevé : $e');
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
        'UsersID': document.data['UsersID'],
      };
    } catch (e) {
      throw Exception('Erreur lors de la récupération du channel : $e');
    }
  }

  // Récupérer un channel en fonction de son ID et de son nom
  // Param :
  // - channelID: ID du channel
  // - channelName: nom du channel
  Future<int> getChannelIdByName(String userId, String channelName) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: databaseID,
        collectionId: collectionChannelsID,
        queries: [
          Query.equal('Nom', channelName),
        ],
      );
      print('Réponse de la base de données: ${response.documents.length} documents trouvés');

      for (var document in response.documents) {
        List<dynamic> users = document.data['UsersID'];
        if (users.contains(userId)) {
          return int.parse(document.$id);
        }
      }

      throw Exception('Channel not found');
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'ID du channel : $e');
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

      List<dynamic> users = channelDocument.data['UsersID'];
      if (users.contains(userID)) {
        throw Exception('Utilisateur déjà ajouté au channel');
      }

      users.add(userID);

      print('Users avant la mise à jour: $users');

      await _databases.updateDocument(
        databaseId: databaseID,
        collectionId: collectionChannelsID,
        documentId: channelID.toString(),
        data: {
          'UsersID': users,
        },
      );

      print('Utilisateur ajouté au channel avec succès.');
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de l\'utilisateur au channel : $e');
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
      List<dynamic> users = channelDocument.data['UsersID'] ?? [];

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

  // Supprime un channel de la base de données
  // Params
  // - channelId: ID du channel
  Future<void> deleteChannel(int channelId) async {
    try {
      await _databases.deleteDocument(
        databaseId: databaseID,
        collectionId: collectionChannelsID,
        documentId: channelId.toString(),
      );
      print('Channel supprimé avec succès');
    } catch (e) {
      throw Exception('Erreur lors de la suppression du channel : $e');
    }
  }
}
