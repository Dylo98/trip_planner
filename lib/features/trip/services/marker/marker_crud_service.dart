import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/services/base_trip_service.dart';

/// Serwis odpowiedzialny za operacje CRUD na markerach w podróży
///
/// Zawiera metody do:
/// - Dodawania markera do podróży
/// - Usuwania markera z podróży (wraz ze zdjęciami)
class MarkerCrudService extends BaseTripService {
  MarkerCrudService({
    required super.firestore,
    required super.auth,
    required super.storage,
  });

  /// Dodaje nowy marker do podróży
  Future<void> addMarkerToTrip(String tripId, MarkerPoint marker) async {
    requireUserId();

    final tripRef = getTripRef(tripId);

    final doc = await tripRef.get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('Podróż nie istnieje');
    }

    final trip = Trip.fromJson(doc.data()!);
    final updatedMarkers = [...trip.markerPoints, marker];

    await tripRef.update({
      'markerPoints': updatedMarkers.map((m) => m.toJson()).toList(),
    });
  }

  /// Usuwa marker z podróży wraz ze wszystkimi jego zdjęciami
  Future<void> deleteMarkerFromTrip(String tripId, String markerId) async {
    requireUserId();

    final tripRef = getTripRef(tripId);

    final doc = await tripRef.get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('Podróż nie istnieje');
    }

    final trip = Trip.fromJson(doc.data()!);

    final markerToDelete = trip.markerPoints.firstWhere(
      (m) => m.id == markerId,
      orElse: () => throw Exception('Marker nie istnieje'),
    );

    await _deleteMarkerImages(markerToDelete);

    final updatedMarkers =
        trip.markerPoints.where((marker) => marker.id != markerId).toList();

    await tripRef.update({
      'markerPoints': updatedMarkers.map((m) => m.toJson()).toList(),
    });
  }

  /// Helper do usuwania wszystkich zdjęć markera
  Future<void> _deleteMarkerImages(MarkerPoint marker) async {
    if (marker.imageUrl == null) return;

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
