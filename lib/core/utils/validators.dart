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
      return "Musisz podać nazwę";
    }
    return null;
  }
}
