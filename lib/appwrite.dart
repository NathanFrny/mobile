import 'package:test/test.dart';
import 'package:appwrite/appwrite.dart';

void main() {
  test('Créer un utilisateur', () async {
    final client = Client()
        .setEndpoint(
            'https://appwrite.thimotebois.ovh:9443/v1') // Your API Endpoint
        .setProject('66009da23c66a5968ef9'); // Your project ID

    final account = Account(client);

    final user = await account.create(
      userId: ID.unique(),
      email: 'testuser@example.com',
      password: 'testpassword',
    );

    expect(user.$id, isNotNull); // Vérifiez que l'ID utilisateur n'est pas null
  });
}
