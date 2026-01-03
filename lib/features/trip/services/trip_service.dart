import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/budget/model/expense_item_model.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/services/trip/trip_crud_service.dart';
import 'package:trip_planner/features/trip/services/trip/trip_image_service.dart';
import 'package:trip_planner/features/trip/services/trip/trip_deletion_service.dart';
import 'package:trip_planner/features/trip/services/marker/marker_crud_service.dart';
import 'package:trip_planner/features/trip/services/marker/marker_update_service.dart';
import 'package:trip_planner/features/trip/services/marker/marker_image_service.dart';
import 'package:trip_planner/features/budget/services/trip_expense_service.dart';

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
    );

    _tripExpenseService = TripExpenseService(
      firestore: _firestore,
      auth: _auth,
      storage: _storage,
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
  late final TripExpenseService _tripExpenseService;

  Future<void> saveTrip(Trip trip) => _tripCrudService.saveTrip(trip);
  Future<Trip?> getTrip(String tripId) => _tripCrudService.getTrip(tripId);
  Stream<Trip> watchTrip(String tripId) => _tripCrudService.watchTrip(tripId);
  Stream<List<Trip>> getTrips(String uid) => _tripCrudService.getTrips(uid);

  Future<String> uploadTripImage(File imageFile, String tripId) =>
      _tripImageService.uploadTripImage(imageFile, tripId);

  Future<void> deleteTripImage(String imageUrl) =>
      _tripImageService.deleteTripImage(imageUrl);

  Future<void> addMarkerToTrip(String tripId, MarkerPoint marker) =>
      _markerCrudService.addMarkerToTrip(tripId, marker);

  Future<void> deleteMarkerFromTrip(String tripId, String markerId) =>
      _markerCrudService.deleteMarkerFromTrip(tripId, markerId);

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

  Future<void> updateMarkerExpenses({
    required String tripId,
    required String markerId,
    required List<ExpenseItem> expenses,
  }) =>
      _markerUpdateService.updateMarkerExpenses(
        tripId: tripId,
        markerId: markerId,
        expenses: expenses,
      );

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
      );

  Future<void> deleteMarkerImage(String imageUrl) =>
      _markerImageService.deleteMarkerImage(imageUrl);

  Future<void> deleteTrip(String tripId) =>
      _tripDeletionService.deleteTrip(tripId);

  Future<void> updateMarkerDescription({
    required String tripId,
    required String markerId,
    required String description,
  }) =>
      _markerUpdateService.updateMarkerDescription(
        tripId: tripId,
        markerId: markerId,
        description: description,
      );

  Future<void> updateMarkerName({
    required String tripId,
    required String markerId,
    required String name,
  }) =>
      _markerUpdateService.updateMarkerName(
        tripId: tripId,
        markerId: markerId,
        name: name,
      );

  Future<void> addTripExpense({
    required String tripId,
    required ExpenseItem expense,
  }) =>
      _tripExpenseService.addTripExpense(
        tripId: tripId,
        expense: expense,
      );

  Future<void> deleteTripExpense({
    required String tripId,
    required String expenseId,
  }) =>
      _tripExpenseService.deleteTripExpense(
        tripId: tripId,
        expenseId: expenseId,
      );

  Future<void> updateTripExpense({
    required String tripId,
    required ExpenseItem expense,
  }) =>
      _tripExpenseService.updateTripExpense(
        tripId: tripId,
        expense: expense,
      );

  Future<List<ExpenseItem>> getTripExpenses(String tripId) =>
      _tripExpenseService.getTripExpenses(tripId);

  Future<void> updateTripPhoto(String tripId, String? photoUrl) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not logged in');

    String ownerId = uid;

    final ownTripDoc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('trips')
        .doc(tripId)
        .get();

    if (!ownTripDoc.exists) {
      final sharedTripDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('shared_trips')
          .doc(tripId)
          .get();

      if (sharedTripDoc.exists && sharedTripDoc.data() != null) {
        final data = sharedTripDoc.data()!;
        ownerId = data['ownerId'] as String? ?? uid;
      }
    }

    await _firestore
        .collection('users')
        .doc(ownerId)
        .collection('trips')
        .doc(tripId)
        .update({
      'tripPhotoUrl': photoUrl,
    });
  }

  Future<void> updateTripDates(
    String tripId,
    DateTime startDate,
    DateTime? endDate,
  ) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not logged in');

    String ownerId = uid;

    final ownTripDoc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('trips')
        .doc(tripId)
        .get();

    if (!ownTripDoc.exists) {
      final sharedTripDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('shared_trips')
          .doc(tripId)
          .get();

      if (sharedTripDoc.exists && sharedTripDoc.data() != null) {
        final data = sharedTripDoc.data()!;
        ownerId = data['ownerId'] as String? ?? uid;
      }
    }

    await _firestore
        .collection('users')
        .doc(ownerId)
        .collection('trips')
        .doc(tripId)
        .update({
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate) : null,
    });
  }

  Future<void> updateTripName(String tripId, String name) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not logged in');

    String ownerId = uid;

    final ownTripDoc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('trips')
        .doc(tripId)
        .get();

    if (!ownTripDoc.exists) {
      final sharedTripDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('shared_trips')
          .doc(tripId)
          .get();

      if (sharedTripDoc.exists && sharedTripDoc.data() != null) {
        final data = sharedTripDoc.data()!;
        ownerId = data['ownerId'] as String? ?? uid;
      }
    }

    await _firestore
        .collection('users')
        .doc(ownerId)
        .collection('trips')
        .doc(tripId)
        .update({
      'name': name,
    });
  }
}

final tripServiceProvider = Provider<TripService>((ref) {
  return TripService(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});
