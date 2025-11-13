import 'dart:convert';
import 'package:http/http.dart' as http;

/// Serwis odpowiedzialny za pobieranie zdjęć miejsc z Wikipedia/Wikimedia/Wikidata
///
/// Próbuje pobrać zdjęcia w kolejności:
/// 1. Wikimedia Commons
/// 2. Wikidata
/// 3. Wikipedia
/// 4. Bezpośredni link z tagu 'image'
class NominatimImageService {
  static Future<String?> getImageFromTags(Map<String, dynamic> tags) async {
    String? photoUrl;

    final wikimedia = tags['wikimedia_commons'] as String?;
    if (wikimedia != null) {
      photoUrl = await getWikimediaImage(wikimedia);
      if (photoUrl != null) return photoUrl;
    }

    final wikidata = tags['wikidata'] as String?;
    if (wikidata != null) {
      photoUrl = await getWikidataImage(wikidata);
      if (photoUrl != null) return photoUrl;
    }

    final wikipedia = tags['wikipedia'] as String?;
    if (wikipedia != null) {
      photoUrl = await getWikipediaImage(wikipedia);
      if (photoUrl != null) return photoUrl;
    }

    final imageTag = tags['image'] as String?;
    if (imageTag != null && imageTag.startsWith('http')) {
      return imageTag;
    }

    return null;
  }

  static Future<String?> getWikimediaImage(String wikimediaRef) async {
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

      if (pages == null) return null;

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

  static Future<String?> getWikidataImage(String wikidataId) async {
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
          return getWikimediaImage('File:$imageName');
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getWikipediaImage(String wikipediaRef) async {
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

      if (pages == null) return null;

      final page = pages.values.first;
      return page['thumbnail']?['source'] as String?;
    } catch (e) {
      return null;
    }
  }
}
