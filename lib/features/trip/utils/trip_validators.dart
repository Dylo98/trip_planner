import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/core/utils/validators.dart';

class TripValidators {
  static String? validateTripDatesWithConflicts({
    required DateTime? startDate,
    required DateTime? endDate,
    required List<Trip> existingTrips,
    String? currentTripId,
  }) {
    final basicError = Validators.validateTripDates(
      startDate: startDate,
      endDate: endDate,
    );
    if (basicError != null) return basicError;

    if (startDate == null) return 'Data rozpoczęcia jest wymagana';

    final ongoingTrips = existingTrips.where((trip) {
      return trip.id != currentTripId &&
          trip.tripType == TripType.ongoing &&
          trip.status == TripStatus.ongoing;
    }).toList();

    if (endDate == null) {
      if (ongoingTrips.isNotEmpty) {
        return 'Możesz mieć tylko jedną trwającą podróż. Zakończ obecną podróż "${ongoingTrips.first.name}" przed utworzeniem nowej.';
      }
      final now = DateTime.now();
      final currentlyActiveTrips = existingTrips.where((trip) {
        if (trip.id == currentTripId) return false;
        if (trip.startDate == null) return false;

        final tripEnd = trip.endDate ?? trip.startDate!;

        final isCurrentlyActive = !trip.startDate!.isAfter(now) &&
            !tripEnd.isBefore(DateTime(now.year, now.month, now.day));

        return isCurrentlyActive;
      }).toList();

      if (currentlyActiveTrips.isNotEmpty) {
        final active = currentlyActiveTrips.first;
        return 'Obecnie trwa podróż "${active.name}" (${_formatDate(active.startDate!)}${active.endDate != null ? ' - ${_formatDate(active.endDate!)}' : ''}). Zakończ ją przed utworzeniem nowej trwającej podróży.';
      }
    } else {
      final conflictingTrips = existingTrips.where((trip) {
        if (trip.id == currentTripId) return false;
        if (trip.startDate == null) return false;

        final tripStart = trip.startDate!;
        final tripEnd = trip.endDate ?? tripStart;

        final overlaps = (startDate.isBefore(tripEnd) ||
                startDate.isAtSameMomentAs(tripEnd)) &&
            (endDate.isAfter(tripStart) || endDate.isAtSameMomentAs(tripStart));

        return overlaps;
      }).toList();

      if (conflictingTrips.isNotEmpty) {
        final conflicting = conflictingTrips.first;
        return 'Podróż nakłada się z "${conflicting.name}" (${_formatDate(conflicting.startDate!)} - ${_formatDate(conflicting.endDate ?? conflicting.startDate!)})';
      }
    }

    return null;
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
