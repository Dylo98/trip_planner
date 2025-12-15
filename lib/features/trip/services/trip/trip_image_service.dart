import 'dart:io';
import 'package:trip_planner/features/trip/services/base_trip_service.dart';
import 'package:trip_planner/core/utils/error_logger.dart';

/// Serwis odpowiedzialny za zarządzanie zdjęciami głównej podróży
///
/// Zawiera metody do:
/// - Uploadowania zdjęcia podróży
/// - Usuwania starego zdjęcia przy update
class TripImageService extends BaseTripService {
  TripImageService({
    required super.firestore,
    required super.auth,
    required super.storage,
  });

  /// Uploaduje zdjęcie główne podróży do Firebase Storage
  Future<String> uploadTripImage(File imageFile, String tripId) async {
    final uid = requireUserId();

    final tripDoc = await firestore
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
    final storageRef = storage
        .ref()
        .child('users/$uid/trips/$tripId/trip_photo_$timestamp.jpg');

    await storageRef.putFile(imageFile);
    final downloadUrl = await storageRef.getDownloadURL();

    if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
      await _deleteImageFromStorage(oldImageUrl);
    }

    return downloadUrl;
  }

  /// Usuwa zdjęcie podróży z Firebase Storage
  Future<void> deleteTripImage(String imageUrl) async {
    await _deleteImageFromStorage(imageUrl);
  }

  /// Helper do usuwania zdjęcia z Storage
  Future<void> _deleteImageFromStorage(String imageUrl) async {
    try {
      final imageRef = storage.refFromURL(imageUrl);
      await imageRef.delete();
    } catch (e, stackTrace) {
      // Błąd podczas usuwania zdjęcia jest akceptowalny (np. zdjęcie już usunięte)
      ErrorLogger.warn(
        'Nie udało się usunąć zdjęcia: $imageUrl',
        context: 'TripImageService._deleteImageFromStorage',
      );
      ErrorLogger.log(
        'Szczegóły błędu podczas usuwania zdjęcia',
        error: e,
        stackTrace: stackTrace,
        context: 'TripImageService',
      );
    }
  }
}
