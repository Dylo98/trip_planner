import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw _handleAuthException(error);
    }
  }

  Future<UserCredential> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      if (name.trim().isEmpty) {
        throw AuthException('Imię nie może być puste');
      }
      if (name.trim().length < 2) {
        throw AuthException('Imię musi mieć co najmniej 2 znaki');
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthException('Nie udało się utworzyć użytkownika');
      }

      await _firestore.collection('users').doc(user.uid).set({
        'email': email.trim(),
        'name': name.trim(),
        'avatar': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await user.updateDisplayName(name.trim());

      return credential;
    } on FirebaseAuthException catch (error) {
      throw _handleAuthException(error);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Nieoczekiwany błąd: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw _handleAuthException(error);
    }
  }

  AuthException _handleAuthException(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return AuthException('Nieprawidłowy adres e-mail');
      case 'user-disabled':
        return AuthException('Konto zostało zablokowane');
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return AuthException('Nieprawidłowe dane logowania');
      case 'email-already-in-use':
        return AuthException('Adres e-mail jest już zajęty');
      case 'weak-password':
        return AuthException('Hasło jest zbyt słabe (min. 6 znaków)');
      case 'network-request-failed':
        return AuthException('Brak połączenia z internetem');
      case 'too-many-requests':
        return AuthException('Zbyt wiele prób. Spróbuj później');
      default:
        return AuthException(error.message ?? 'Nieznany błąd');
    }
  }
}
