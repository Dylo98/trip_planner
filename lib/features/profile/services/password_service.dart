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

  /// Parsuje błędy Firebase Auth na przyjazne komunikaty po polsku
  String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'wrong-password':
          return 'Nieprawidłowe obecne hasło';
        case 'weak-password':
          return 'Nowe hasło jest zbyt słabe (minimum 6 znaków)';
        case 'requires-recent-login':
          return 'Musisz się ponownie zalogować, aby zmienić hasło';
        case 'user-disabled':
          return 'Twoje konto zostało wyłączone';
        case 'user-not-found':
          return 'Nie znaleziono użytkownika';
        case 'network-request-failed':
          return 'Brak połączenia z internetem';
        case 'too-many-requests':
          return 'Zbyt wiele prób. Spróbuj ponownie później';
        default:
          return 'Błąd podczas zmiany hasła';
      }
    }

    if (error.toString().contains('Użytkownik nie jest zalogowany')) {
      return 'Musisz być zalogowany';
    }

    return 'Nie udało się zmienić hasła';
  }
}
