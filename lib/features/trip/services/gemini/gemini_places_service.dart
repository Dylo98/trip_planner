import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner/features/trip/services/nominatim/nominatim_model.dart';
import 'dart:convert';

/// Serwis używający Google Gemini AI do inteligentnego wyszukiwania miejsc
///
/// Gemini AI znajduje popularne, interesujące miejsca w okolicy
/// na podstawie kontekstu (atrakcje turystyczne, restauracje, etc.)
class GeminiPlacesService {
  // ZMIEŃ TO NA SWÓJ KLUCZ API!
  // Pobierz z: https://makersuite.google.com/app/apikey
  static const String apiKey = 'AIzaSyBLALEaxBSjWRO2ImFY0xN4ImLTF1oXEHc';

  /// Wyszukuje miejsca używając AI Gemini
  static Future<List<PlaceSuggestion>> getAISuggestedPlaces({
    required LatLng center,
    required String query,
    int limit = 10,
  }) async {
    try {
      // Dla wersji 0.4.7 używamy takiej składni
      final model = GenerativeModel(
        model: 'gemini-1.5-flash', // Bez prefiksu "models/"
        apiKey: apiKey,
      );

      final prompt = _buildPrompt(center, query, limit);

      print('🤖 Wysyłam zapytanie do Gemini...');

      // Generuj odpowiedź
      final response = await model.generateContent([Content.text(prompt)]);

      final text = response.text;

      if (text == null || text.isEmpty) {
        print('⚠️ Gemini zwróciło pustą odpowiedź');
        return [];
      }

      print('✅ Otrzymano odpowiedź od Gemini (${text.length} znaków)');

      // Parsuj odpowiedź JSON
      return _parseGeminiResponse(text);
    } catch (e, stackTrace) {
      print('❌ Błąd Gemini AI: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  /// Buduje prompt dla Gemini AI
  static String _buildPrompt(LatLng center, String query, int limit) {
    return '''
Znajdź $limit najpopularniejszych i najciekawszych miejsc typu "$query" 
w okolicy współrzędnych ${center.latitude}, ${center.longitude} (promień około 3-5 km).

WYMAGANIA:
- Tylko ISTNIEJĄCE, popularne i dobrze znane miejsca
- Współrzędne GPS muszą być DOKŁADNE i w promieniu ~5km od podanego punktu
- Opis w języku POLSKIM (2-3 zdania, konkretny i pomocny dla turysty)
- Uwzględnij różnorodność (nie tylko jeden typ miejsc)

Zwróć TYLKO czysty JSON w formacie (bez markdown, bez \`\`\`json):
{
  "places": [
    {
      "name": "pełna nazwa miejsca",
      "latitude": 50.061389,
      "longitude": 19.936944,
      "description": "Krótki, praktyczny opis miejsca dla turysty",
      "category": "attraction"
    }
  ]
}

KATEGORIE (używaj tylko tych):
- "attraction" - atrakcje turystyczne, zabytki, punkty widokowe
- "historic" - zamki, muzea, miejsca historyczne
- "food" - restauracje, kawiarnie, bary
- "nature" - parki, góry, jeziora, rezerwaty
- "culture" - teatry, galerie, centra kultury

ZWRÓĆ TYLKO JSON, BEZ ŻADNEGO INNEGO TEKSTU!
''';
  }

  /// Parsuje odpowiedź JSON z Gemini
  static List<PlaceSuggestion> _parseGeminiResponse(String text) {
    try {
      // Wyczyść odpowiedź z ewentualnego markdown
      String cleanJson = text.trim();

      // Usuń ```json i ``` jeśli Gemini je doda
      if (cleanJson.contains('```json')) {
        cleanJson = cleanJson.replaceAll('```json', '');
      }
      if (cleanJson.contains('```')) {
        cleanJson = cleanJson.replaceAll('```', '');
      }
      cleanJson = cleanJson.trim();

      print(
          '📝 Parsowanie JSON: ${cleanJson.substring(0, cleanJson.length > 100 ? 100 : cleanJson.length)}...');

      // Parsuj JSON
      final json = jsonDecode(cleanJson);

      if (json is! Map<String, dynamic> || !json.containsKey('places')) {
        print('❌ Nieprawidłowy format JSON - brak klucza "places"');
        return [];
      }

      final placesJson = json['places'] as List;

      print('✅ Gemini zwróciło ${placesJson.length} miejsc');

      // Konwertuj na PlaceSuggestion
      return placesJson
          .map((place) {
            try {
              return PlaceSuggestion(
                name: place['name'] as String,
                location: LatLng(
                  (place['latitude'] as num).toDouble(),
                  (place['longitude'] as num).toDouble(),
                ),
                address: null,
                photoReference: null,
                category: _categoryFromString(place['category'] as String),
                details: PlaceDetails(
                  description: place['description'] as String,
                ),
              );
            } catch (e) {
              print('⚠️ Błąd parsowania miejsca: $e');
              return null;
            }
          })
          .whereType<PlaceSuggestion>()
          .toList();
    } catch (e) {
      print('❌ Błąd parsowania JSON z Gemini: $e');
      print('Surowa odpowiedź:\n$text');
      return [];
    }
  }

  /// Konwertuje string kategorii na enum
  static PlaceCategory _categoryFromString(String category) {
    switch (category.toLowerCase()) {
      case 'attraction':
        return PlaceCategory.attraction;
      case 'historic':
        return PlaceCategory.historic;
      case 'food':
        return PlaceCategory.food;
      case 'nature':
        return PlaceCategory.nature;
      case 'culture':
        return PlaceCategory.culture;
      default:
        return PlaceCategory.unknown;
    }
  }
}
