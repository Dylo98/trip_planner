import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Parsuje błędy Firebase na przyjazne komunikaty po polsku
  String getErrorMessage(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'storage/unauthorized':
          return 'Brak uprawnień do uploadu zdjęcia';
        case 'storage/canceled':
          return 'Upload został anulowany';
        case 'storage/unknown':
          return 'Wystąpił nieznany błąd podczas uploadu';
        case 'storage/quota-exceeded':
          return 'Przekroczono limit miejsca na zdjęcia';
        case 'storage/unauthenticated':
          return 'Musisz być zalogowany aby dodać zdjęcie';
        case 'permission-denied':
          return 'Brak uprawnień do zapisu';
        case 'unavailable':
          return 'Serwer jest niedostępny, spróbuj ponownie';
        default:
          return 'Błąd podczas zapisu zdjęcia';
      }
    }

    if (error.toString().contains('Użytkownik nie jest zalogowany')) {
      return 'Musisz być zalogowany';
    }

    return 'Nie udało się zapisać zdjęcia';
  }

  Future<String> uploadAvatar(File imageFile) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Użytkownik nie jest zalogowany');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final storageRef =
        _storage.ref().child('users/$userId/profile/avatar_$timestamp.jpg');

    await storageRef.putFile(imageFile);

    final downloadUrl = await storageRef.getDownloadURL();

    await _firestore.collection('users').doc(userId).update({
      'avatar': downloadUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _auth.currentUser?.updatePhotoURL(downloadUrl);

    return downloadUrl;
  }

  Future<String> uploadCoverImage(File imageFile) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Użytkownik nie jest zalogowany');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final storageRef =
        _storage.ref().child('users/$userId/profile/cover_$timestamp.jpg');

    await storageRef.putFile(imageFile);

    final downloadUrl = await storageRef.getDownloadURL();

    await _firestore.collection('users').doc(userId).update({
      'coverImage': downloadUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return downloadUrl;
  }

  Future<void> deleteAvatar() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Użytkownik nie jest zalogowany');
    }

    await _firestore.collection('users').doc(userId).update({
      'avatar': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _auth.currentUser?.updatePhotoURL(null);
  }

  Future<void> deleteCoverImage() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Użytkownik nie jest zalogowany');
    }

    await _firestore.collection('users').doc(userId).update({
      'coverImage': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
