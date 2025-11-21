import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trip_planner/features/schedule/model/day_plan_model.dart';
import 'package:trip_planner/features/schedule/model/day_plan_item_model.dart';
import 'package:trip_planner/features/budget/model/expense_item_model.dart';

class DayPlanService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DayPlanService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Użytkownik niezalogowany');
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _getDayPlansCollection(
      String tripId) {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('trips')
        .doc(tripId)
        .collection('dayPlans');
  }

  Future<void> saveDayPlan(String tripId, DayPlan dayPlan) async {
    final docRef = _getDayPlansCollection(tripId).doc(dayPlan.dateKey);
    await docRef.set(dayPlan.toJson());
  }

  Future<DayPlan?> getDayPlan(String tripId, DateTime date) async {
    final dateKey = _formatDateKey(date);
    final doc = await _getDayPlansCollection(tripId).doc(dateKey).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return DayPlan.fromJson(doc.data()!);
  }

  Stream<DayPlan> watchDayPlan(String tripId, DateTime date) {
    final dateKey = _formatDateKey(date);
    return _getDayPlansCollection(tripId).doc(dateKey).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return DayPlan.empty(date);
      }
      return DayPlan.fromJson(doc.data()!);
    });
  }

  Future<List<DayPlan>> getAllDayPlans(String tripId) async {
    final snapshot = await _getDayPlansCollection(tripId).get();

    return snapshot.docs
        .map((doc) {
          try {
            return DayPlan.fromJson(doc.data());
          } catch (e) {
            return null;
          }
        })
        .whereType<DayPlan>()
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Stream<List<DayPlan>> watchAllDayPlans(String tripId) {
    return _getDayPlansCollection(tripId).snapshots().map((snapshot) {
      final plans = snapshot.docs
          .map((doc) {
            try {
              return DayPlan.fromJson(doc.data());
            } catch (e) {
              return null;
            }
          })
          .whereType<DayPlan>()
          .toList();

      plans.sort((a, b) => a.date.compareTo(b.date));
      return plans;
    });
  }

  Future<void> addItemToDayPlan(
    String tripId,
    DateTime date,
    DayPlanItem item,
  ) async {
    final dateKey = _formatDateKey(date);
    final docRef = _getDayPlansCollection(tripId).doc(dateKey);

    final doc = await docRef.get();
    DayPlan dayPlan;

    if (doc.exists && doc.data() != null) {
      dayPlan = DayPlan.fromJson(doc.data()!);
      final updatedItems = [...dayPlan.items, item];
      dayPlan = dayPlan.copyWith(items: updatedItems);
    } else {
      dayPlan = DayPlan(date: date, items: [item]);
    }

    await docRef.set(dayPlan.toJson());
  }

  Future<void> removeItemFromDayPlan(
    String tripId,
    DateTime date,
    String itemId,
  ) async {
    final dateKey = _formatDateKey(date);
    final docRef = _getDayPlansCollection(tripId).doc(dateKey);

    final doc = await docRef.get();
    if (!doc.exists || doc.data() == null) return;

    final dayPlan = DayPlan.fromJson(doc.data()!);
    final updatedItems =
        dayPlan.items.where((item) => item.id != itemId).toList();

    if (updatedItems.isEmpty) {
      await docRef.delete();
    } else {
      final updatedPlan = dayPlan.copyWith(items: updatedItems);
      await docRef.set(updatedPlan.toJson());
    }
  }

  Future<void> updateItemInDayPlan(
    String tripId,
    DateTime date,
    DayPlanItem updatedItem,
  ) async {
    final dateKey = _formatDateKey(date);
    final docRef = _getDayPlansCollection(tripId).doc(dateKey);

    final doc = await docRef.get();
    if (!doc.exists || doc.data() == null) return;

    final dayPlan = DayPlan.fromJson(doc.data()!);
    final updatedItems = dayPlan.items.map((item) {
      return item.id == updatedItem.id ? updatedItem : item;
    }).toList();

    final updatedPlan = dayPlan.copyWith(items: updatedItems);
    await docRef.set(updatedPlan.toJson());
  }

  Future<void> updateItemExpenses(
    String tripId,
    DateTime date,
    String itemId,
    List<ExpenseItem> expenses,
  ) async {
    final dateKey = _formatDateKey(date);
    final docRef = _getDayPlansCollection(tripId).doc(dateKey);

    final doc = await docRef.get();
    if (!doc.exists || doc.data() == null) return;

    final dayPlan = DayPlan.fromJson(doc.data()!);
    final updatedItems = dayPlan.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(expenses: expenses);
      }
      return item;
    }).toList();

    final updatedPlan = dayPlan.copyWith(items: updatedItems);
    await docRef.set(updatedPlan.toJson());
  }

  Future<void> reorderDayPlanItems(
    String tripId,
    DateTime date,
    List<DayPlanItem> reorderedItems,
  ) async {
    final dateKey = _formatDateKey(date);
    final docRef = _getDayPlansCollection(tripId).doc(dateKey);

    final doc = await docRef.get();
    if (!doc.exists || doc.data() == null) return;

    final dayPlan = DayPlan.fromJson(doc.data()!);

    final itemsWithNewOrder = reorderedItems.asMap().entries.map((entry) {
      return entry.value.copyWith(order: entry.key);
    }).toList();

    final updatedPlan = dayPlan.copyWith(items: itemsWithNewOrder);
    await docRef.set(updatedPlan.toJson());
  }

  Future<void> deleteAllDayPlans(String tripId) async {
    final snapshot = await _getDayPlansCollection(tripId).get();
    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<void> generateEmptyPlansForTrip(
    String tripId,
    DateTime startDate,
    DateTime? endDate,
  ) async {
    final end = endDate ?? startDate;
    final days = end.difference(startDate).inDays + 1;

    final batch = _firestore.batch();

    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final dateKey = _formatDateKey(date);
      final docRef = _getDayPlansCollection(tripId).doc(dateKey);

      final existingDoc = await docRef.get();
      if (!existingDoc.exists) {
        final emptyPlan = DayPlan.empty(date);
        batch.set(docRef, emptyPlan.toJson());
      }
    }

    await batch.commit();
  }

  String _formatDateKey(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
