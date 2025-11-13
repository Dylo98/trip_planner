import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/services/trip_crud_service.dart';
import 'package:trip_planner/features/trip/services/trip_image_service.dart';
import 'package:trip_planner/features/trip/services/trip_deletion_service.dart';
import 'package:trip_planner/features/trip/services/marker/marker_crud_service.dart';
import 'package:trip_planner/features/trip/services/marker/marker_update_service.dart';
import 'package:trip_planner/features/trip/services/marker/marker_image_service.dart';

/// Główny serwis TripService - Facade Pattern
///
/// Deleguje odpowiedzialności do wyspecjalizowanych serwisów:
/// - TripCrudService - podstawowe operacje CRUD na podróżach
/// - TripImageService - zarządzanie zdjęciami podróży
/// - TripDeletionService - usuwanie podróży z zasobami
/// - MarkerCrudService - operacje CRUD na markerach
/// - MarkerUpdateService - aktualizacja danych markerów
/// - MarkerImageService - zarządzanie zdjęciami markerów
class TripService {
  TripService(
    FirebaseFirestore firestore,
    FirebaseAuth auth, [
    FirebaseStorage? storage,
  ])  : _firestore = firestore,
        _auth = auth,
        _storage = storage ?? FirebaseStorage.instance {
    _tripCrudService = TripCrudService(
      firestore: _firestore,
      auth: _auth,
      storage: _storage,
    );

    _tripImageService = TripImageService(
      firestore: _firestore,
      auth: _auth,
      storage: _storage,
    );

    _tripDeletionService = TripDeletionService(
      firestore: _firestore,
      auth: _auth,
      storage: _storage,
    );

    _markerCrudService = MarkerCrudService(
      firestore: _firestore,
      auth: _auth,
      storage: _storage,
    );

    _markerUpdateService = MarkerUpdateService(
      firestore: _firestore,
      auth: _auth,
      storage: _storage,
    );

    _markerImageService = MarkerImageService(
      firestore: _firestore,
      auth: _auth,
      storage: _storage,
      tripCrudService: _tripCrudService,
    );
  }

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  late final TripCrudService _tripCrudService;
  late final TripImageService _tripImageService;
  late final TripDeletionService _tripDeletionService;
  late final MarkerCrudService _markerCrudService;
  late final MarkerUpdateService _markerUpdateService;
  late final MarkerImageService _markerImageService;

  // =============================
  // TRIPS – ZAPIS / ODCZYT PODRÓŻY
  // =============================

  /// Zapisuje podróż do Firestore
  Future<void> saveTrip(Trip trip) => _tripCrudService.saveTrip(trip);

  /// Pobiera pojedynczą podróż po ID
  Future<Trip?> getTrip(String tripId) => _tripCrudService.getTrip(tripId);

  /// Obserwuje zmiany w podróży w czasie rzeczywistym
  Stream<Trip> watchTrip(String tripId) => _tripCrudService.watchTrip(tripId);

  /// Pobiera wszystkie podróże użytkownika jako Stream
  Stream<List<Trip>> getTrips(String uid) => _tripCrudService.getTrips(uid);

  // =============================
  // TRIPS – ZDJĘCIA
  // =============================

  /// Uploaduje zdjęcie główne podróży do Firebase Storage
  Future<String> uploadTripImage(File imageFile, String tripId) =>
      _tripImageService.uploadTripImage(imageFile, tripId);

  /// Usuwa zdjęcie podróży z Firebase Storage
  Future<void> deleteTripImage(String imageUrl) =>
      _tripImageService.deleteTripImage(imageUrl);

  // =============================
  // MARKERY – DODAWANIE / USUWANIE
  // =============================

  /// Dodaje nowy marker do podróży
  Future<void> addMarkerToTrip(String tripId, MarkerPoint marker) =>
      _markerCrudService.addMarkerToTrip(tripId, marker);

  /// Usuwa marker z podróży wraz ze wszystkimi jego zdjęciami
  Future<void> deleteMarkerFromTrip(String tripId, String markerId) =>
      _markerCrudService.deleteMarkerFromTrip(tripId, markerId);

  // =============================
  // MARKERY – AKTUALIZACJA
  // =============================

  /// Aktualizuje daty przyjazdu i wyjazdu dla markera
  Future<void> updateMarkerDates({
    required String tripId,
    required String markerId,
    required DateTime arrival,
    required DateTime departure,
  }) =>
      _markerUpdateService.updateMarkerDates(
        tripId: tripId,
        markerId: markerId,
        arrival: arrival,
        departure: departure,
      );

  /// Aktualizuje środek transportu dla markera
  Future<void> updateMarkerTransportMode({
    required String tripId,
    required String markerId,
    required String transportMode,
  }) =>
      _markerUpdateService.updateMarkerTransportMode(
        tripId: tripId,
        markerId: markerId,
        transportMode: transportMode,
      );

  /// Aktualizuje wydatek dla markera
  Future<void> updateMarkerExpense({
    required String tripId,
    required String markerId,
    required double expense,
  }) =>
      _markerUpdateService.updateMarkerExpense(
        tripId: tripId,
        markerId: markerId,
        expense: expense,
      );

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
  }) =>
      _markerImageService.addImageToMarker(
        tripId: tripId,
        markerId: markerId,
        image: image,
        arrival: arrival,
        departure: departure,
      );

  /// Usuwa zdjęcie markera z Firebase Storage
  Future<void> deleteMarkerImage(String imageUrl) =>
      _markerImageService.deleteMarkerImage(imageUrl);

  // =============================
  // TRIPS – USUWANIE
  // =============================

  /// Usuwa podróż wraz ze wszystkimi powiązanymi zasobami
  Future<void> deleteTrip(String tripId) =>
      _tripDeletionService.deleteTrip(tripId);
}

final tripServiceProvider = Provider<TripService>((ref) {
  return TripService(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});
