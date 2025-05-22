import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TripService {
  TripService(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> saveTrip(Trip trip) async {
    final uid = _auth.currentUser?.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('trips')
        .doc(trip.id)
        .set(trip.toJson());
  }

  Future<String> uploadTripImage(File imageFile, String tripId) async {
    final uid = _auth.currentUser?.uid;
    final ref =
        _storage.ref().child('users/$uid/trips/$tripId/${DateTime.now()}');
    await ref.putFile(imageFile);
    final downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }
}

final tripServiceProvider = Provider<TripService>((ref) {
  return TripService(FirebaseFirestore.instance, FirebaseAuth.instance);
});
