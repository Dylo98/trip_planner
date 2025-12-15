import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trip_planner/features/profile/model/notification_settings_model.dart';

class NotificationSettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<NotificationSettings> getNotificationSettings() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Użytkownik nie jest zalogowany');
    }

    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('notifications')
        .get();

    if (doc.exists) {
      return NotificationSettings.fromMap(doc.data()!);
    }

    return const NotificationSettings();
  }

  Future<void> updateNotificationSettings(
      NotificationSettings settings) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Użytkownik nie jest zalogowany');
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('notifications')
        .set({
      ...settings.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
