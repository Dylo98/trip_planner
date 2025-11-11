import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';

class TripService {
  TripService(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // =============================
  // TRIPS – ZAPIS / ODCZYT PODRÓŻY
  // =============================

  Future<void> saveTrip(Trip trip) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Użytkownik niezalogowany');
    }

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('trips')
          .doc(trip.id)
          .set(trip.toJson());
    } catch (e) {
      throw Exception('Nie udało się zapisać podróży: $e');
    }
  }

  Future<Trip?> getTrip(String tripId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('trips')
          .doc(tripId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return Trip.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Nie udało się pobrać podróży: $e');
    }
  }

  Stream<Trip> watchTrip(String tripId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.error(Exception('Użytkownik niezalogowany'));
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('trips')
        .doc(tripId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) {
        throw Exception('Podróż nie istnieje');
      }
      try {
        return Trip.fromJson(doc.data()!);
      } catch (e) {
        throw Exception('Błąd parsowania danych podróży: $e');
      }
    });
  }

  Stream<List<Trip>> getTrips(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('trips')
        .snapshots()
        .map((snapshot) {
      final trips = <Trip>[];
      for (final doc in snapshot.docs) {
        try {
          if (doc.data().isNotEmpty) {
            trips.add(Trip.fromJson(doc.data()));
          }
        } catch (e) {
          print('Error parsing trip ${doc.id}: $e');
        }
      }
      return trips;
    });
  }

  // =============================
  // TRIPS – ZDJĘCIA
  // =============================

  Future<String> uploadTripImage(File imageFile, String tripId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Użytkownik niezalogowany');
    }

    try {
      final tripDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('trips')
          .doc(tripId)
          .get();

      String? oldImageUrl;
      if (tripDoc.exists && tripDoc.data() != null) {
        oldImageUrl = tripDoc.data()!['tripPhotoUrl'] as String?;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = _storage
          .ref()
          .child('users/$uid/trips/$tripId/trip_photo_$timestamp.jpg');

      await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();

      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        try {
          final oldRef = _storage.refFromURL(oldImageUrl);
          await oldRef.delete();
          print('✅ Deleted old trip image');
        } catch (e) {
          print('⚠️ Failed to delete old trip image: $e');
        }
      }

      return downloadUrl;
    } catch (e) {
      throw Exception('Nie udało się przesłać zdjęcia: $e');
    }
  }

  // =============================
  // MARKERY – DODAWANIE / AKTUALIZACJA
  // =============================

  Future<void> addMarkerToTrip(String tripId, MarkerPoint marker) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Użytkownik niezalogowany');
    }

    try {
      final tripRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('trips')
          .doc(tripId);

      final doc = await tripRef.get();
      if (!doc.exists || doc.data() == null) {
        throw Exception('Podróż nie istnieje');
      }

      final trip = Trip.fromJson(doc.data()!);
      final updatedMarkers = [...trip.markerPoints, marker];

      await tripRef.update({
        'markerPoints': updatedMarkers.map((m) => m.toJson()).toList(),
      });
    } catch (e) {
      throw Exception('Nie udało się dodać markera: $e');
    }
  }

  Future<void> updateMarkerDates({
    required String tripId,
    required String markerId,
    required DateTime arrival,
    required DateTime departure,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Użytkownik niezalogowany');
    }

    try {
      final tripRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('trips')
          .doc(tripId);

      final doc = await tripRef.get();
      if (!doc.exists || doc.data() == null) {
        throw Exception('Podróż nie istnieje');
      }

      final trip = Trip.fromJson(doc.data()!);

      final updatedMarkers = trip.markerPoints.map((marker) {
        if (marker.id == markerId) {
          return marker.copyWith(
            arrivalDateTime: arrival,
            departureDateTime: departure,
          );
        }
        return marker;
      }).toList();

      await tripRef.update({
        'markerPoints': updatedMarkers.map((m) => m.toJson()).toList(),
      });
    } catch (e) {
      throw Exception('Nie udało się zaktualizować dat: $e');
    }
  }

  Future<void> updateMarkerTransportMode({
    required String tripId,
    required String markerId,
    required String transportMode,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Użytkownik niezalogowany');
    }

    try {
      final tripRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('trips')
          .doc(tripId);

      final tripSnap = await tripRef.get();
      if (!tripSnap.exists || tripSnap.data() == null) {
        return;
      }

      final data = tripSnap.data()!;

      if (!data.containsKey('markerPoints') || data['markerPoints'] is! List) {
        return;
      }

      final markers = List<Map<String, dynamic>>.from(data['markerPoints']);
      final index = markers.indexWhere((m) => m['id'] == markerId);

      if (index == -1) return;

      markers[index]['transportMode'] = transportMode;

      await tripRef.update({'markerPoints': markers});
    } catch (e) {
      throw Exception('Nie udało się zaktualizować transportu: $e');
    }
  }

  Future<void> updateMarkerExpense({
    required String tripId,
    required String markerId,
    required double expense,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Użytkownik niezalogowany');
    }

    try {
      final tripRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('trips')
          .doc(tripId);

      final tripSnap = await tripRef.get();
      if (!tripSnap.exists || tripSnap.data() == null) {
        return;
      }

      final data = tripSnap.data()!;

      if (!data.containsKey('markerPoints') || data['markerPoints'] is! List) {
        return;
      }

      final markers = List<Map<String, dynamic>>.from(data['markerPoints']);
      final index = markers.indexWhere((m) => m['id'] == markerId);

      if (index == -1) return;

      markers[index]['expense'] = expense;

      await tripRef.update({'markerPoints': markers});
    } catch (e) {
      throw Exception('Nie udało się zaktualizować wydatku: $e');
    }
  }
  // =============================
  // MARKERY – ZDJĘCIA
  // =============================

  Future<void> addImageToMarker({
    required String tripId,
    required String markerId,
    required File image,
    DateTime? arrival,
    DateTime? departure,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Użytkownik niezalogowany');
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = _storage.ref().child(
          'users/$uid/trips/$tripId/markers/$markerId/image_$timestamp.jpg');

      await storageRef.putFile(image);
      final imageUrl = await storageRef.getDownloadURL();

      final tripDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('trips')
          .doc(tripId)
          .get();

      if (!tripDoc.exists || tripDoc.data() == null) {
        throw Exception('Podróż nie istnieje');
      }

      final trip = Trip.fromJson(tripDoc.data()!);

      final updatedMarkers = trip.markerPoints.map((marker) {
        if (marker.id == markerId) {
          final updatedUrls = List<String>.from(marker.imageUrl ?? [])
            ..add(imageUrl);
          return marker.copyWith(
            imageUrl: updatedUrls,
            arrivalDateTime: arrival ?? marker.arrivalDateTime,
            departureDateTime: departure ?? marker.departureDateTime,
          );
        }
        return marker;
      }).toList();

      final updatedTrip = trip.copyWith(markerPoints: updatedMarkers);
      await saveTrip(updatedTrip);
    } catch (e) {
      throw Exception('Nie udało się dodać zdjęcia: $e');
    }
  }

  // =============================
  // MARKERY – USUWANIE
  // =============================

  Future<void> deleteMarkerFromTrip(String tripId, String markerId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Użytkownik niezalogowany');
    }

    try {
      final tripRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('trips')
          .doc(tripId);

      final doc = await tripRef.get();
      if (!doc.exists || doc.data() == null) {
        throw Exception('Podróż nie istnieje');
      }

      final trip = Trip.fromJson(doc.data()!);

      final markerToDelete = trip.markerPoints.firstWhere(
        (m) => m.id == markerId,
        orElse: () => throw Exception('Marker nie istnieje'),
      );

      if (markerToDelete.imageUrl != null) {
        for (final imageUrl in markerToDelete.imageUrl!) {
          try {
            final imageRef = _storage.refFromURL(imageUrl);
            await imageRef.delete();
            print('✅ Deleted image: $imageUrl');
          } catch (e) {
            print('⚠️ Failed to delete image: $e');
          }
        }
      }

      final updatedMarkers =
          trip.markerPoints.where((marker) => marker.id != markerId).toList();

      await tripRef.update({
        'markerPoints': updatedMarkers.map((m) => m.toJson()).toList(),
      });
    } catch (e) {
      throw Exception('Nie udało się usunąć markera: $e');
    }
  }

  // =============================
  // TRIPS – USUWANIE
  // =============================

  Future<void> deleteTrip(String tripId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Użytkownik niezalogowany');
    }

    try {
      final tripDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('trips')
          .doc(tripId)
          .get();

      if (tripDoc.exists && tripDoc.data() != null) {
        final trip = Trip.fromJson(tripDoc.data()!);

        if (trip.tripPhotoUrl != null) {
          try {
            final photoRef = _storage.refFromURL(trip.tripPhotoUrl!);
            await photoRef.delete();
          } catch (e) {
            print('⚠️ Failed to delete trip photo: $e');
          }
        }

        for (final marker in trip.markerPoints) {
          if (marker.imageUrl != null) {
            for (final imageUrl in marker.imageUrl!) {
              try {
                final imageRef = _storage.refFromURL(imageUrl);
                await imageRef.delete();
              } catch (e) {
                print('⚠️ Failed to delete marker image: $e');
              }
            }
          }
        }
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('trips')
          .doc(tripId)
          .delete();
    } catch (e) {
      throw Exception('Nie udało się usunąć podróży: $e');
    }
  }
}

final tripServiceProvider = Provider<TripService>((ref) {
  return TripService(FirebaseFirestore.instance, FirebaseAuth.instance);
});
