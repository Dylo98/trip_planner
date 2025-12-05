import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/budget/model/expense_item_model.dart';
import 'package:trip_planner/features/trip/services/base_trip_service.dart';

class TripExpenseService extends BaseTripService {
  TripExpenseService({
    required super.firestore,
    required super.auth,
    required super.storage,
  });

  Future<void> addTripExpense({
    required String tripId,
    required ExpenseItem expense,
  }) async {
    requireUserId();

    final ownerId = await getTripOwnerId(tripId);
    final tripRef = getTripRefWithOwner(tripId, ownerId);

    final doc = await tripRef.get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('Podróż nie istnieje');
    }

    final tripData = doc.data()!;
    tripData['id'] = tripId;
    final trip = Trip.fromFirestore(tripData);
    final updatedExpenses = [...?trip.tripExpenses, expense];

    await tripRef.update({
      'tripExpenses': updatedExpenses.map((e) => e.toJson()).toList(),
    });
  }

  Future<void> deleteTripExpense({
    required String tripId,
    required String expenseId,
  }) async {
    requireUserId();

    final ownerId = await getTripOwnerId(tripId);
    final tripRef = getTripRefWithOwner(tripId, ownerId);

    final doc = await tripRef.get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('Podróż nie istnieje');
    }

    final tripData = doc.data()!;
    tripData['id'] = tripId;
    final trip = Trip.fromFirestore(tripData);

    if (trip.tripExpenses == null) return;

    final updatedExpenses =
        trip.tripExpenses!.where((expense) => expense.id != expenseId).toList();

    await tripRef.update({
      'tripExpenses': updatedExpenses.map((e) => e.toJson()).toList(),
    });
  }

  Future<void> updateTripExpense({
    required String tripId,
    required ExpenseItem expense,
  }) async {
    requireUserId();

    final ownerId = await getTripOwnerId(tripId);
    final tripRef = getTripRefWithOwner(tripId, ownerId);

    final doc = await tripRef.get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('Podróż nie istnieje');
    }

    final tripData = doc.data()!;
    tripData['id'] = tripId;
    final trip = Trip.fromFirestore(tripData);

    if (trip.tripExpenses == null) return;

    final updatedExpenses = trip.tripExpenses!.map((e) {
      if (e.id == expense.id) {
        return expense;
      }
      return e;
    }).toList();

    await tripRef.update({
      'tripExpenses': updatedExpenses.map((e) => e.toJson()).toList(),
    });
  }

  Future<List<ExpenseItem>> getTripExpenses(String tripId) async {
    requireUserId();

    final ownerId = await getTripOwnerId(tripId);
    final tripRef = getTripRefWithOwner(tripId, ownerId);

    final doc = await tripRef.get();
    if (!doc.exists || doc.data() == null) {
      return [];
    }

    final tripData = doc.data()!;
    tripData['id'] = tripId;
    final trip = Trip.fromFirestore(tripData);
    return trip.tripExpenses ?? [];
  }
}
