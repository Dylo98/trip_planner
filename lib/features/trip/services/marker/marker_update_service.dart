import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/model/expense_item_model.dart';
import 'package:trip_planner/features/trip/services/base_trip_service.dart';

/// Serwis odpowiedzialny za aktualizację danych markerów
///
/// Zawiera metody do:
/// - Aktualizacji dat przyjazdu/wyjazdu
/// - Aktualizacji środka transportu
/// - Aktualizacji wydatków (nowa lista wydatków)
class MarkerUpdateService extends BaseTripService {
  MarkerUpdateService({
    required super.firestore,
    required super.auth,
    required super.storage,
  });

  /// Aktualizuje środek transportu dla markera
  Future<void> updateMarkerTransportMode({
    required String tripId,
    required String markerId,
    required String transportMode,
  }) async {
    requireUserId();

    final tripRef = getTripRef(tripId);

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
  }

  Future<void> updateMarkerDescription({
    required String tripId,
    required String markerId,
    required String description,
  }) async {
    requireUserId();

    final tripRef = getTripRef(tripId);

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

    markers[index]['description'] = description;

    await tripRef.update({'markerPoints': markers});
  }

  /// Aktualizuje listę wydatków dla markera (NOWA METODA)
  Future<void> updateMarkerExpenses({
    required String tripId,
    required String markerId,
    required List<ExpenseItem> expenses,
  }) async {
    requireUserId();

    final tripRef = getTripRef(tripId);

    final doc = await tripRef.get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('Podróż nie istnieje');
    }

    final trip = Trip.fromJson(doc.data()!);

    final updatedMarkers = trip.markerPoints.map((marker) {
      if (marker.id == markerId) {
        return marker.copyWith(expenses: expenses);
      }
      return marker;
    }).toList();

    await tripRef.update({
      'markerPoints': updatedMarkers.map((m) => m.toJson()).toList(),
    });
  }

  /// Aktualizuje wydatek dla markera (DEPRECATED - zachowane dla kompatybilności)
  @Deprecated('Użyj updateMarkerExpenses zamiast updateMarkerExpense')
  Future<void> updateMarkerExpense({
    required String tripId,
    required String markerId,
    required double expense,
  }) async {
    requireUserId();

    final tripRef = getTripRef(tripId);

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
  }
}
