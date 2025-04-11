import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _firebase = FirebaseAuth.instance;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _firebase.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signup({
    required String email,
    required String password,
  }) async {
    await _firebase.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
