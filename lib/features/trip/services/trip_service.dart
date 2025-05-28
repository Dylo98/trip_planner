import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/* FIREBASE */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';

/* MODEL */
import 'package:trip_planner/features/trip/model/trip_model.dart';

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

  Future<Trip> getTrip(String tripId) async {
    final uid = _auth.currentUser?.uid;
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('trips')
        .doc(tripId)
        .get();
    return Trip.fromJson(doc.data()!);
  }

  Stream<List<Trip>> getTrips(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('trips')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Trip.fromJson(doc.data())).toList());
  }

  Stream<Trip> watchTrip(String tripId) {
    final uid = _auth.currentUser?.uid;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('trips')
        .doc(tripId)
        .snapshots()
        .map((doc) => Trip.fromJson(doc.data()!));
  }

  Future<void> addImageToMarker({
    required String tripId,
    required String markerId,
    required File image,
  }) async {
    final uid = _auth.currentUser?.uid;

    final storageRef = _storage
        .ref()
        .child('users/$uid/trips/$tripId/markers/$markerId/${DateTime.now()}');
    await storageRef.putFile(image);
    final imageUrl = await storageRef.getDownloadURL();

    final tripDoc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('trips')
        .doc(tripId)
        .get();

    final trip = Trip.fromJson(tripDoc.data()!);

    final updatedMarkers = trip.markerPoints.map((marker) {
      if (marker.id == markerId) {
        final updatedUrls = List<String>.from(marker.imageUrl ?? [])
          ..add(imageUrl);
        return MarkerPoint(
          id: marker.id,
          position: marker.position,
          name: marker.name,
          description: marker.description,
          imageUrl: updatedUrls,
        );
      }
      return marker;
    }).toList();

    final updatedTrip = trip.copyWith(markerPoints: updatedMarkers);
    await saveTrip(updatedTrip);
  }

  Future<void> addMarkerToTrip(String tripId, MarkerPoint marker) async {
    final uid = _auth.currentUser?.uid;
    final tripRef =
        _firestore.collection('users').doc(uid).collection('trips').doc(tripId);
    final doc = await tripRef.get();
    final trip = Trip.fromJson(doc.data()!);

    final updatedMarkers = [...trip.markerPoints, marker];

    await tripRef.update({
      'markerPoints': updatedMarkers.map((m) => m.toJson()).toList(),
    });
    print(
        'Dodawanie markera do tripId: $tripId z uid: $_auth.currentUser?.uid');
  }
}

final tripServiceProvider = Provider<TripService>((ref) {
  return TripService(FirebaseFirestore.instance, FirebaseAuth.instance);
});
