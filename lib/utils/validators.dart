/// Klasa pomocnicza służąca do walidacji danych wpisanych przez użytkownika
///
/// Metody:
/// - [validateEmail] - sprawdza poprawność adresu e-mail
/// - [validatePassword] - sprawdza poprawność hasła
///
/// Metody zwracają:
/// - null - gdy dane są poprawne
/// - Komunikat typu String - gdy wystąpi błąd walidacji
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
}
