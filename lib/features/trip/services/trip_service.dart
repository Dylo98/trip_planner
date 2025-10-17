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

  // =============================
  // TRIPS – ZAPIS / ODCZYT PODRÓŻY
  // =============================

  /// Zapisuje podróż do Firestore
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

  /// Pobiera pojedynczą podróż
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

  /// Obserwuje zmiany w podróży (real-time)
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

  /// Pobiera wszystkie podróże użytkownika (stream)
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
          // Loguj błąd ale nie crashuj całej aplikacji
          print('Error parsing trip ${doc.id}: $e');
        }
      }
      return trips;
    });
  }

  // =============================
  // TRIPS – ZDJĘCIA
  // =============================

  /// Uploaduje zdjęcie podróży do Firebase Storage
  Future<String> uploadTripImage(File imageFile, String tripId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Użytkownik niezalogowany');
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage
          .ref()
          .child('users/$uid/trips/$tripId/trip_photo_$timestamp.jpg');

      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Nie udało się przesłać zdjęcia: $e');
    }
  }

  // =============================
  // MARKERY – DODAWANIE / AKTUALIZACJA
  // =============================

  /// Dodaje marker do podróży
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

  /// Aktualizuje daty przyjazdu/odjazdu dla markera
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

  /// Aktualizuje środek transportu dla markera
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

  // =============================
  // MARKERY – ZDJĘCIA
  // =============================

  /// Dodaje zdjęcie do markera
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
      // Upload do Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = _storage.ref().child(
          'users/$uid/trips/$tripId/markers/$markerId/image_$timestamp.jpg');

      await storageRef.putFile(image);
      final imageUrl = await storageRef.getDownloadURL();

      // Aktualizuj Firestore
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

  /// Usuwa marker z podróży
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

  /// Usuwa całą podróż (opcjonalnie)
  Future<void> deleteTrip(String tripId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Użytkownik niezalogowany');
    }

    try {
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
