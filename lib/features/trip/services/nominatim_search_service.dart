import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceSuggestion {
  final String name;
  final LatLng location;
  final String? address;
  final String? photoReference;
  final double? importance;

  PlaceSuggestion({
    required this.name,
    required this.location,
    this.address,
    this.photoReference,
    this.importance,
  });
}

class NominatimSearchService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  static DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(seconds: 1);

  static Future<void> _ensureRateLimit() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        final waitTime = _minRequestInterval - timeSinceLastRequest;
        await Future.delayed(waitTime);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  static Future<List<PlaceSuggestion>> searchPlaces(
    String query, {
    http.Client? client,
  }) async {
    if (query.trim().isEmpty) return [];

    await _ensureRateLimit();

    final httpClient = client ?? http.Client();
    final shouldCloseClient = client == null;

    final url = Uri.parse('$_baseUrl/search?'
        'q=${Uri.encodeComponent(query)}'
        '&format=json'
        '&addressdetails=1'
        '&limit=10'
        '&dedupe=1');

    try {
      final response = await httpClient.get(
        url,
        headers: {
          'User-Agent': 'TripPlanner/1.0 (contact: dawid.dyl2@wp.pl)',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        return [];
      }

      final List results = json.decode(response.body);

      var suggestions = results.map((place) {
        return PlaceSuggestion(
          name: place['display_name'] as String,
          location: LatLng(
            double.parse(place['lat']),
            double.parse(place['lon']),
          ),
          address: place['display_name'] as String,
          photoReference: null,
          importance: place['importance'] as double?,
        );
      }).toList();

      suggestions.sort((a, b) {
        final impA = a.importance ?? 0.0;
        final impB = b.importance ?? 0.0;
        return impB.compareTo(impA);
      });

      return suggestions.take(5).toList();
    } on http.ClientException {
      return [];
    } catch (e) {
      return [];
    } finally {
      if (shouldCloseClient) {
        httpClient.close();
      }
    }
  }

  static Future<List<PlaceSuggestion>> searchPlacesStructured({
    String? street,
    String? city,
    String? country,
    String? building,
    http.Client? client,
  }) async {
    await _ensureRateLimit();

    final httpClient = client ?? http.Client();
    final shouldCloseClient = client == null;

    final params = <String, String>{
      'format': 'json',
      'addressdetails': '1',
      'limit': '5',
      'dedupe': '1',
    };

    if (street != null) params['street'] = street;
    if (city != null) params['city'] = city;
    if (country != null) params['country'] = country;
    if (building != null) params['building'] = building;

    final url = Uri.parse('$_baseUrl/search').replace(queryParameters: params);

    try {
      final response = await httpClient.get(
        url,
        headers: {
          'User-Agent': 'TripPlanner/1.0 (contact: dawid.dyl2@wp.pl)',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        return [];
      }

      final List results = json.decode(response.body);

      return results.map((place) {
        return PlaceSuggestion(
          name: place['display_name'] as String,
          location: LatLng(
            double.parse(place['lat']),
            double.parse(place['lon']),
          ),
          address: place['display_name'] as String,
          photoReference: null,
          importance: place['importance'] as double?,
        );
      }).toList();
    } on http.ClientException {
      return [];
    } catch (e) {
      return [];
    } finally {
      if (shouldCloseClient) {
        httpClient.close();
      }
    }
  }

  static Future<List<PlaceSuggestion>> getNearbyPlaces(
    LatLng position, {
    int radiusKm = 2,
  }) async {
    final url = Uri.parse('https://overpass-api.de/api/interpreter?'
        'data=[out:json];'
        '('
        'node["tourism"](around:${radiusKm * 1000},${position.latitude},${position.longitude});'
        'node["historic"](around:${radiusKm * 1000},${position.latitude},${position.longitude});'
        'node["amenity"~"restaurant|cafe"](around:${radiusKm * 1000},${position.latitude},${position.longitude});'
        'way["tourism"](around:${radiusKm * 1000},${position.latitude},${position.longitude});'
        'way["historic"](around:${radiusKm * 1000},${position.latitude},${position.longitude});'
        ');'
        'out center tags 20;');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return [];
      }

      final data = json.decode(response.body);
      final elements = data['elements'] as List;

      final suggestions = <PlaceSuggestion>[];

      for (final element in elements) {
        final tags = element['tags'] as Map<String, dynamic>? ?? {};
        final name = tags['name'] as String?;

        if (name == null || name.isEmpty) continue;

        double lat, lon;
        if (element['type'] == 'way' && element['center'] != null) {
          lat = element['center']['lat'] as double;
          lon = element['center']['lon'] as double;
        } else {
          lat = element['lat'] as double;
          lon = element['lon'] as double;
        }

        String? photoUrl;

        final wikimedia = tags['wikimedia_commons'] as String?;
        if (wikimedia != null) {
          photoUrl = await _getWikimediaImage(wikimedia);
        }

        if (photoUrl == null) {
          final wikidata = tags['wikidata'] as String?;
          if (wikidata != null) {
            photoUrl = await _getWikidataImage(wikidata);
          }
        }

        if (photoUrl == null) {
          final wikipedia = tags['wikipedia'] as String?;
          if (wikipedia != null) {
            photoUrl = await _getWikipediaImage(wikipedia);
          }
        }

        if (photoUrl == null) {
          final imageTag = tags['image'] as String?;
          if (imageTag != null && imageTag.startsWith('http')) {
            photoUrl = imageTag;
          }
        }

        suggestions.add(PlaceSuggestion(
          name: name,
          location: LatLng(lat, lon),
          address: name,
          photoReference: photoUrl,
        ));
      }

      return suggestions;
    } catch (e) {
      return [];
    }
  }

  static Future<String?> _getWikimediaImage(String wikimediaRef) async {
    try {
      String fileName = wikimediaRef;
      if (!fileName.startsWith('File:')) {
        fileName = 'File:$fileName';
      }

      fileName = fileName.replaceFirst('File:', '');

      final url = Uri.parse('https://commons.wikimedia.org/w/api.php?'
          'action=query'
          '&titles=File:${Uri.encodeComponent(fileName)}'
          '&prop=imageinfo'
          '&iiprop=url'
          '&iiurlwidth=400'
          '&format=json');

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body);
      final pages = data['query']?['pages'] as Map<String, dynamic>?;

      if (pages == null) {
        return null;
      }

      final page = pages.values.first;
      final imageInfo = page['imageinfo'] as List?;

      if (imageInfo != null && imageInfo.isNotEmpty) {
        return imageInfo[0]['thumburl'] as String?;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> _getWikidataImage(String wikidataId) async {
    try {
      final url = Uri.parse('https://www.wikidata.org/w/api.php?'
          'action=wbgetclaims'
          '&entity=$wikidataId'
          '&property=P18'
          '&format=json');

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body);
      final claims = data['claims']?['P18'] as List?;

      if (claims != null && claims.isNotEmpty) {
        final imageName =
            claims[0]['mainsnak']?['datavalue']?['value'] as String?;

        if (imageName != null) {
          return _getWikimediaImage('File:$imageName');
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> _getWikipediaImage(String wikipediaRef) async {
    try {
      final parts = wikipediaRef.split(':');
      if (parts.length != 2) return null;

      final lang = parts[0];
      final title = parts[1];

      final url = Uri.parse('https://$lang.wikipedia.org/w/api.php?'
          'action=query'
          '&titles=${Uri.encodeComponent(title)}'
          '&prop=pageimages'
          '&pithumbsize=400'
          '&format=json');

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body);
      final pages = data['query']?['pages'] as Map<String, dynamic>?;

      if (pages == null) {
        return null;
      }

      final page = pages.values.first;
      return page['thumbnail']?['source'] as String?;
    } catch (e) {
      return null;
    }
  }
}
