import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Bazowy serwis zawierający wspólne zależności dla wszystkich serwisów trip
abstract class BaseTripService {
  BaseTripService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _auth = auth,
        _storage = storage;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;
  FirebaseStorage get storage => _storage;

  String requireUserId() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Użytkownik niezalogowany');
    }
    return uid;
  }

  DocumentReference<Map<String, dynamic>> getTripRef(String tripId) {
    final uid = requireUserId();
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('trips')
        .doc(tripId);
  }

  DocumentReference<Map<String, dynamic>> getTripRefWithOwner(
    String tripId,
    String ownerId,
  ) {
    return _firestore
        .collection('users')
        .doc(ownerId)
        .collection('trips')
        .doc(tripId);
  }

  Future<String> getTripOwnerId(String tripId) async {
    final currentUid = requireUserId();

    final ownTripDoc = await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('trips')
        .doc(tripId)
        .get();

    if (ownTripDoc.exists) {
      return currentUid;
    }

    final sharedTripDoc = await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('shared_trips')
        .doc(tripId)
        .get();

    if (sharedTripDoc.exists && sharedTripDoc.data() != null) {
      final ownerId = sharedTripDoc.data()!['ownerId'] as String?;
      if (ownerId != null) {
        return ownerId;
      }
    }

    throw Exception('Nie znaleziono podróży');
  }

  CollectionReference<Map<String, dynamic>> getTripsCollection() {
    final uid = requireUserId();
    return _firestore.collection('users').doc(uid).collection('trips');
  }
}
