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

  CollectionReference<Map<String, dynamic>> getTripsCollection() {
    final uid = requireUserId();
    return _firestore.collection('users').doc(uid).collection('trips');
  }
}
