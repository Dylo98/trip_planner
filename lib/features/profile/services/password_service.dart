import 'package:firebase_auth/firebase_auth.dart';

class PasswordService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Użytkownik nie jest zalogowany');
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  String? getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
        return 'Nieprawidłowe obecne hasło';
      case 'weak-password':
        return 'Nowe hasło jest zbyt słabe';
      case 'requires-recent-login':
        return 'Musisz się ponownie zalogować, aby zmienić hasło';
      default:
        return null;
    }
  }
}
