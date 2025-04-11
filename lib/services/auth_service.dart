import 'package:firebase_auth/firebase_auth.dart';

/// Własna klasa błędu używana w AuthService
///
/// Zawiera komunikat, który jest później wyświetlany użytkownikowi
class AuthException implements Exception {
  AuthException(this.message);

  /// Treść błędu do wyświetlenia.
  final String message;
}

/// Klasa odpowiedzialna za logowanie i rejestrację użytkownika.
///
/// Korzysta z Firebase Authentication do obsługi autoryzacji.
class AuthService {
  final _firebase = FirebaseAuth.instance;

  /// Metoda logowania użytkownika
  ///
  /// Parametry:
  /// - [email] - Adres e-mail użytkownika
  /// - [password] - Hasło użytkownika
  ///
  /// Rzuca:
  /// - [AuthException] - jeśli wystąpi błąd przy logowaniu z powodu
  ///   - Niepoprawny e-mail
  ///   -Nieprawidłowe dane logowania
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _firebase.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      if (error.code == 'invalid-email') {
        throw AuthException('Błędny adres e-mail');
      } else if (error.code == 'user-not-found') {
        throw AuthException('Niepoprawne dane logowania');
      } else {
        throw AuthException('Nieudana próba zalogowania.');
      }
    }
  }

  /// Metoda rejestracji użytkownika
  ///
  /// Parametry:
  /// - [email] - Adres e-mail użytkownika
  /// - [password] - Hasło użytkownika
  ///
  /// Rzuca:
  /// - [AuthException] - jeśli wystąpi błąd przy rejestracji z powodu
  ///   - Zajętego e-maila
  ///   - Słabego hasła
  ///   - Niepoprawnego e-maila
  Future<void> signup({
    required String email,
    required String password,
  }) async {
    try {
      await _firebase.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        throw AuthException('Adres e-mail jest już zajęty.');
      } else if (error.code == 'invalid-email') {
        throw AuthException('Adres e-mail jest nie poprawny.');
      } else if (error.code == 'weak-password') {
        throw AuthException('Hasło jest zbyt słabe');
      } else {
        throw AuthException('Nieudana próba rejestracji');
      }
    }
  }
}
