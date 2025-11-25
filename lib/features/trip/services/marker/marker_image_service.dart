import 'dart:io';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/services/base_trip_service.dart';

/// Serwis odpowiedzialny za zarządzanie zdjęciami markerów
///
/// Zawiera metody do:
/// - Dodawania zdjęcia do markera
/// - Aktualizacji dat przy dodawaniu zdjęcia
class MarkerImageService extends BaseTripService {
  MarkerImageService({
    required super.firestore,
    required super.auth,
    required super.storage,
  });

  /// Dodaje zdjęcie do markera
  Future<void> addImageToMarker({
    required String tripId,
    required String markerId,
    required File image,
  }) async {
    requireUserId();

    final ownerId = await getTripOwnerId(tripId);

    final imageUrl = await _uploadMarkerImage(
      uid: ownerId,
      tripId: tripId,
      markerId: markerId,
      imageFile: image,
    );

    final tripRef = getTripRefWithOwner(tripId, ownerId);
    final tripDoc = await tripRef.get();

    if (!tripDoc.exists || tripDoc.data() == null) {
      throw Exception('Podróż nie istnieje');
    }

    final tripData = tripDoc.data()!;
    tripData['id'] = tripId;
    final trip = Trip.fromFirestore(tripData);

    final updatedMarkers = trip.markerPoints.map((marker) {
      if (marker.id == markerId) {
        final updatedUrls = List<String>.from(marker.imageUrl ?? [])
          ..add(imageUrl);
        return marker.copyWith(
          imageUrl: updatedUrls,
        );
      }
      return marker;
    }).toList();

    final updatedTrip = trip.copyWith(markerPoints: updatedMarkers);

    await tripRef.set(updatedTrip.toJson());
  }

  /// Uploaduje zdjęcie markera do Firebase Storage
  Future<String> _uploadMarkerImage({
    required String uid,
    required String tripId,
    required String markerId,
    required File imageFile,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storageRef = storage.ref().child(
        'users/$uid/trips/$tripId/markers/$markerId/image_$timestamp.jpg');

    await storageRef.putFile(imageFile);
    return await storageRef.getDownloadURL();
  }

  /// Usuwa zdjęcie markera z Firebase Storage
  Future<void> deleteMarkerImage(String imageUrl) async {
    try {
      final imageRef = storage.refFromURL(imageUrl);
      await imageRef.delete();
    } catch (e) {
      //
    }
  }
}
