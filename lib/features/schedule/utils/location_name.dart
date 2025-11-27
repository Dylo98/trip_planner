class LocationName {
  static const List<String> _separators = [',', '-', '–', '—', '|', '(', '/'];

  static String getShortName(String? fullName,
      {String fallback = 'Bez nazwy'}) {
    if (fullName == null) return fallback;

    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return fallback;

    for (final separator in _separators) {
      final index = trimmed.indexOf(separator);
      if (index != -1) {
        return trimmed.substring(0, index).trim();
      }
    }

    return trimmed;
  }
}
