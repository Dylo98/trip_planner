import 'package:firebase_auth/firebase_auth.dart';

class AuthException implements Exception {
  AuthException(this.message);

  final String message;
}

class AuthService {
  final _firebase = FirebaseAuth.instance;

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
