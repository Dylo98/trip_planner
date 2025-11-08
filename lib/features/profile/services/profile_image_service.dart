import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadAvatar(File imageFile) async {
    try {
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
    } catch (e) {
      throw Exception('Błąd podczas uploadu zdjęcia profilowego: $e');
    }
  }

  Future<String> uploadCoverImage(File imageFile) async {
    try {
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
    } catch (e) {
      throw Exception('Błąd podczas uploadu zdjęcia w tle: $e');
    }
  }

  Future<void> deleteAvatar() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Użytkownik nie jest zalogowany');
      }

      await _firestore.collection('users').doc(userId).update({
        'avatar': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _auth.currentUser?.updatePhotoURL(null);
    } catch (e) {
      throw Exception('Błąd podczas usuwania zdjęcia profilowego: $e');
    }
  }

  Future<void> deleteCoverImage() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Użytkownik nie jest zalogowany');
      }

      await _firestore.collection('users').doc(userId).update({
        'coverImage': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Błąd podczas usuwania zdjęcia w tle: $e');
    }
  }
}
