import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../model/app_user.dart';

class UserRepository {
  UserRepository({
    FirebaseFirestore? firestore,
    fb.FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? fb.FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final fb.FirebaseAuth _auth;

  Stream<AppUser?> watchMe() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _firestore.collection('users').doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return AppUser.fromJson(uid, snap.data()!);
    });
  }

  Future<AppUser?> getMe() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromJson(uid, doc.data()!);
  }

  Future<void> updateProfile({String? name, String? avatar}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Brak zalogowanego użytkownika');
    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name.trim();
    if (avatar != null) payload['avatar'] = avatar.trim();
    await _firestore
        .collection('users')
        .doc(uid)
        .set(payload, SetOptions(merge: true));
  }
}
