import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

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
    try {
      await _account.deleteSession(
        sessionId: 'current',
      );
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la session : $e');
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

  Future<String> getCurrentUserName() async {
    try {
      final user = await _account.get();
      return user.name;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du nom utilisateur : $e');
    }
  }

  Future<String> getCurrentUserId() async {
    try {
      final user = await _account.get();
      return user.$id;
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération de l\'ID utilisateur : $e');
    }
  }
}


// ---------------------------
//  Gestion des messages
// ---------------------------


//---------------------------
//  Gestion des channels
// ---------------------------