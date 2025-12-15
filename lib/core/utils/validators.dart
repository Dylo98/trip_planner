import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/core/constants/validation_constants.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-mail jest wymagany';
    }

    final email = value.trim();

    final emailRegex = RegExp(ValidationConstants.emailRegexPattern);

    if (!emailRegex.hasMatch(email)) {
      return 'Nieprawidłowy format e-mail';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Hasło jest wymagane';
    }

    if (value.length < ValidationConstants.minPasswordLength) {
      return 'Hasło musi zawierać minimum ${ValidationConstants.minPasswordLength} znaków';
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Imię jest wymagane';
    }

    if (value.trim().length < ValidationConstants.minNameLength) {
      return 'Imię musi mieć co najmniej ${ValidationConstants.minNameLength} znaki';
    }

    if (value.trim().length > ValidationConstants.maxNameLength) {
      return 'Imię nie może być dłuższe niż ${ValidationConstants.maxNameLength} znaków';
    }

    return null;
  }

  static String? validateTripName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Musisz podać nazwę podróży';
    }

    if (value.trim().length < ValidationConstants.minTripNameLength) {
      return 'Nazwa podróży musi mieć min. ${ValidationConstants.minTripNameLength} znaki';
    }

    if (value.trim().length > ValidationConstants.maxTripNameLength) {
      return 'Nazwa podróży jest za długa (max. ${ValidationConstants.maxTripNameLength} znaków)';
    }

    return null;
  }

  static String? validateTripDates({
    required DateTime? startDate,
    required DateTime? endDate,
  }) {
    if (startDate == null) {
      return 'Musisz wybrać datę rozpoczęcia podróży';
    }

    if (endDate != null && startDate.isAfter(endDate)) {
      return 'Data rozpoczęcia nie może być późniejsza niż data zakończenia';
    }

    final now = DateTime.now();
    final maxPastDate = DateTime(
      now.year - ValidationConstants.maxPastYears,
      now.month,
      now.day,
    );

    if (startDate.isBefore(maxPastDate)) {
      return 'Data podróży nie może być starsza niż ${ValidationConstants.maxPastYears} lat';
    }

    return null;
  }

  static String? validateStartDate(DateTime? value) {
    if (value == null) {
      return 'Musisz wybrać datę rozpoczęcia';
    }
    return null;
  }

  static String? validateEndDate({
    required DateTime? endDate,
    required DateTime? startDate,
  }) {
    if (endDate == null) {
      return null;
    }

    if (startDate != null && endDate.isBefore(startDate)) {
      return 'Data zakończenia nie może być wcześniejsza niż data rozpoczęcia';
    }

    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName jest wymagane';
    }
    return null;
  }

  static String? validateTripDatesWithConflicts({
    required DateTime? startDate,
    required DateTime? endDate,
    required List<Trip> existingTrips,
    String? currentTripId,
  }) {
    final basicError = validateTripDates(
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

  static String? validateExpenseTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wpisz tytuł wydatku';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wpisz kwotę';
    }

    final amountStr = value.replaceAll(',', '.');
    final amount = double.tryParse(amountStr);

    if (amount == null || amount <= 0) {
      return 'Wpisz poprawną kwotę';
    }

    return null;
  }
}
