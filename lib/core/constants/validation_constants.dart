/// Stałe dla walidacji formularzy
class ValidationConstants {
  // Email validation
  static const String emailRegexPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  // Password validation
  static const int minPasswordLength = 6;

  // Name validation
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // Trip name validation
  static const int minTripNameLength = 3;
  static const int maxTripNameLength = 100;

  // Trip form field limits
  static const int maxTripFormNameLength = 40;
  static const int maxTripFormDescriptionLength = 100;

  // Trip dates validation
  static const int maxPastYears = 10;

  // Day plan validation
  static const int maxDayPlanDuration = 365;
}
