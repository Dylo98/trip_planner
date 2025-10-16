class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-mail jest wymagany';
    }

    final email = value.trim();

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Nieprawidłowy format e-mail';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Hasło jest wymagane';
    }

    if (value.length < 6) {
      return 'Hasło musi zawierać minimum 6 znaków';
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Imię jest wymagane';
    }

    if (value.trim().length < 2) {
      return 'Imię musi mieć co najmniej 2 znaki';
    }

    if (value.trim().length > 50) {
      return 'Imię nie może być dłuższe niż 50 znaków';
    }

    return null;
  }

  static String? validateTripName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Musisz podać nazwę podróży';
    }

    if (value.trim().length < 3) {
      return 'Nazwa podróży musi mieć min. 3 znaki';
    }

    if (value.trim().length > 100) {
      return 'Nazwa podróży jest za długa (max. 100 znaków)';
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
    final maxPastDate = DateTime(now.year - 10, now.month, now.day);

    if (startDate.isBefore(maxPastDate)) {
      return 'Data podróży nie może być starsza niż 10 lat';
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
}
