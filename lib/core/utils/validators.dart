import 'package:trip_planner/features/trip/model/trip_model.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty || !value.contains('@')) {
      return 'Niepoprawny e-mail.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().length < 6) {
      return 'Hasło musi zawierać minimum 6 znaków';
    }
    return null;
  }

  static String? validateTripName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Musisz podać nazwę podróży";
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
    return null;
  }
}
