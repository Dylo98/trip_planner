import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/services/base_trip_service.dart';

/// Serwis odpowiedzialny za usuwanie podróży
///
/// Zawiera logikę do:
/// - Usuwania podróży wraz ze wszystkimi zdjęciami
/// - Usuwania zdjęcia głównego podróży
/// - Usuwania wszystkich zdjęć markerów
class TripDeletionService extends BaseTripService {
  TripDeletionService({
    required super.firestore,
    required super.auth,
    required super.storage,
  });

  /// Usuwa podróż wraz ze wszystkimi powiązanymi zasobami
  Future<void> deleteTrip(String tripId) async {
    final uid = requireUserId();

    final tripDoc = await firestore
        .collection('users')
        .doc(uid)
        .collection('trips')
        .doc(tripId)
        .get();

    if (tripDoc.exists && tripDoc.data() != null) {
      final trip = Trip.fromJson(tripDoc.data()!);

      await _deleteTripMainImage(trip);

      await _deleteAllMarkerImages(trip);
    }

    await firestore
        .collection('users')
        .doc(uid)
        .collection('trips')
        .doc(tripId)
        .delete();
  }

  /// Usuwa zdjęcie główne podróży
  Future<void> _deleteTripMainImage(Trip trip) async {
    if (trip.tripPhotoUrl == null) return;

    try {
      final photoRef = storage.refFromURL(trip.tripPhotoUrl!);
      await photoRef.delete();
    } catch (e) {
      //
    }
  }

  /// Usuwa wszystkie zdjęcia ze wszystkich markerów podróży
  Future<void> _deleteAllMarkerImages(Trip trip) async {
    for (final marker in trip.markerPoints) {
      if (marker.imageUrl == null) continue;

      for (final imageUrl in marker.imageUrl!) {
        try {
          final imageRef = storage.refFromURL(imageUrl);
          await imageRef.delete();
        } catch (e) {
          //
        }
      }
    }
  }
}
