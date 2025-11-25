import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/services/base_trip_service.dart';

/// Serwis odpowiedzialny za podstawowe operacje CRUD na podróżach
///
/// Zawiera metody do:
/// - Zapisywania podróży
/// - Pobierania pojedynczej podróży
/// - Obserwowania zmian w podróży (Stream)
/// - Pobierania listy wszystkich podróży użytkownika
class TripCrudService extends BaseTripService {
  TripCrudService({
    required super.firestore,
    required super.auth,
    required super.storage,
  });

  /// Zapisuje podróż do Firestore
  Future<void> saveTrip(Trip trip) async {
    final uid = requireUserId();

    await firestore
        .collection('users')
        .doc(uid)
        .collection('trips')
        .doc(trip.id)
        .set(trip.toJson());
  }

  /// Pobiera pojedynczą podróż po ID
  Future<Trip?> getTrip(String tripId) async {
    try {
      requireUserId();

      final ownerId = await getTripOwnerId(tripId);
      final tripRef = getTripRefWithOwner(tripId, ownerId);

      final doc = await tripRef.get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final tripData = doc.data()!;
      tripData['id'] = doc.id;
      return Trip.fromFirestore(tripData);
    } catch (e) {
      return null;
    }
  }

  /// Obserwuje zmiany w podróży w czasie rzeczywistym
  Stream<Trip> watchTrip(String tripId) async* {
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Użytkownik niezalogowany');
    }
    String? ownerId;

    try {
      ownerId = await getTripOwnerId(tripId);
    } catch (e) {
      throw Exception('Podróż nie istnieje');
    }

    yield* firestore
        .collection('users')
        .doc(ownerId)
        .collection('trips')
        .doc(tripId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) {
        throw Exception('Podróż nie istnieje');
      }
      final tripData = doc.data()!;
      tripData['id'] = doc.id;
      return Trip.fromFirestore(tripData);
    });
  }

  /// Pobiera wszystkie podróże użytkownika jako Stream
  Stream<List<Trip>> getTrips(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('trips')
        .snapshots()
        .map((snapshot) {
      final trips = <Trip>[];
      for (final doc in snapshot.docs) {
        try {
          if (doc.data().isNotEmpty) {
            final tripData = doc.data();
            tripData['id'] = doc.id;
            final trip = Trip.fromFirestore(tripData);
            trips.add(trip);
          }
        } catch (e) {
          //
        }
      }
      return trips;
    });
  }
}
