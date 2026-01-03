import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trip_planner/features/auth/constants/auth_messages.dart';

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
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (error) {
      throw _handleAuthException(error);
    } catch (e) {
      throw AuthException(AuthMessages.unexpectedError);
    }
  }

  Future<UserCredential> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // ETAP 1: Walidacja danych
      if (name.trim().isEmpty) {
        throw AuthException(AuthMessages.nameEmpty);
      }
      if (name.trim().length < 2) {
        throw AuthException(AuthMessages.nameTooShort);
      }

      // ETAP 2: Utworzenie konta w Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthException(AuthMessages.userCreationFailed);
      }

      // ETAP 3: Zapis profilu w Firestore
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
      throw AuthException('${AuthMessages.unexpectedError}: ${e.toString()}');
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
        return AuthException(AuthMessages.invalidEmail);
      case 'user-disabled':
        return AuthException(AuthMessages.userDisabled);
      case 'user-not-found':
        return AuthException(AuthMessages.userNotFound);
      case 'wrong-password':
        return AuthException(AuthMessages.wrongPassword);
      case 'invalid-credential':
        return AuthException(AuthMessages.invalidCredential);
      case 'email-already-in-use':
        return AuthException(AuthMessages.emailInUse);
      case 'weak-password':
        return AuthException(AuthMessages.weakPassword);
      case 'network-request-failed':
        return AuthException(AuthMessages.noInternet);
      case 'too-many-requests':
        return AuthException(AuthMessages.tooManyRequests);
      default:
        return AuthException(error.message ?? AuthMessages.unknownError);
    }
  }
}
