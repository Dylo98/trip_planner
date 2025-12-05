import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/statistics/model/traveler_statistics.dart';
import 'package:trip_planner/features/statistics/service/geocoding_service.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';

class CitiesLoaderState {
  final Map<String, List<CityVisit>> citiesByCountry;
  final bool isLoading;
  final int loadedCount;
  final int totalCount;

  CitiesLoaderState({
    required this.citiesByCountry,
    required this.isLoading,
    required this.loadedCount,
    required this.totalCount,
  });

  CitiesLoaderState copyWith({
    Map<String, List<CityVisit>>? citiesByCountry,
    bool? isLoading,
    int? loadedCount,
    int? totalCount,
  }) {
    return CitiesLoaderState(
      citiesByCountry: citiesByCountry ?? this.citiesByCountry,
      isLoading: isLoading ?? this.isLoading,
      loadedCount: loadedCount ?? this.loadedCount,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

class CitiesLoaderNotifier extends StateNotifier<CitiesLoaderState> {
  CitiesLoaderNotifier()
      : super(CitiesLoaderState(
          citiesByCountry: {},
          isLoading: false,
          loadedCount: 0,
          totalCount: 0,
        ));

  Future<void> loadCities(List<MarkerPoint> markers) async {
    if (state.isLoading || state.loadedCount >= markers.length) return;

    state = state.copyWith(
      isLoading: true,
      totalCount: markers.length,
    );

    final citiesByCountry =
        Map<String, List<CityVisit>>.from(state.citiesByCountry);
    final seenCities = <String>{};

    for (final cities in citiesByCountry.values) {
      for (final city in cities) {
        final country = await _getCountryFromCoordinates(
          city.latitude,
          city.longitude,
        );
        seenCities
            .add('${city.cityName.toLowerCase()}_${country.toLowerCase()}');
      }
    }

    int loadedCount = state.loadedCount;

    final batchSize = 5;
    final startIndex = loadedCount;
    final endIndex = (startIndex + batchSize).clamp(0, markers.length);

    for (int i = startIndex; i < endIndex; i++) {
      final marker = markers[i];

      final country = await _getCountryFromCoordinates(
        marker.position.latitude,
        marker.position.longitude,
      );

      final cityName = await GeocodingService.getCityFromCoordinates(
        marker.position.latitude,
        marker.position.longitude,
      );

      if (cityName != null && cityName.isNotEmpty) {
        final cityKey = '${cityName.toLowerCase()}_${country.toLowerCase()}';

        if (!seenCities.contains(cityKey)) {
          seenCities.add(cityKey);

          final cityVisit = CityVisit(
            cityName: cityName,
            latitude: marker.position.latitude,
            longitude: marker.position.longitude,
          );

          if (!citiesByCountry.containsKey(country)) {
            citiesByCountry[country] = [];
          }
          citiesByCountry[country]!.add(cityVisit);
        }
      }

      loadedCount++;

      state = state.copyWith(
        citiesByCountry: Map.from(citiesByCountry),
        loadedCount: loadedCount,
      );

      await Future.delayed(const Duration(seconds: 1));
    }

    state = state.copyWith(isLoading: false);
  }

  void reset() {
    state = CitiesLoaderState(
      citiesByCountry: {},
      isLoading: false,
      loadedCount: 0,
      totalCount: 0,
    );
  }

  static Future<String> _getCountryFromCoordinates(
    double lat,
    double lng,
  ) async {
    try {
      final country =
          await GeocodingService.getCountryFromCoordinates(lat, lng);
      if (country != null && country.isNotEmpty) {
        return country;
      }
    } catch (e) {
//
    }

    if (lat >= 49 && lat <= 54.5 && lng >= 14 && lng <= 24) {
      return 'Polska';
    } else if (lat >= 47 && lat <= 55 && lng >= 5.5 && lng <= 15.5) {
      return 'Niemcy';
    } else if (lat >= 42 && lat <= 51.5 && lng >= -5.5 && lng <= 10) {
      return 'Francja';
    } else if (lat >= 35 && lat <= 47.5 && lng >= 6 && lng <= 19) {
      return 'Włochy';
    } else if (lat >= 36 && lat <= 44 && lng >= -9.5 && lng <= 3.5) {
      return 'Hiszpania';
    } else if (lat >= 25 && lat <= 49 && lng >= -125 && lng <= -66) {
      return 'USA';
    } else if (lat >= 41 && lat <= 82 && lng >= 19 && lng <= 180) {
      return 'Rosja';
    }

    return 'Inne';
  }
}

final citiesLoaderProvider =
    StateNotifierProvider.autoDispose<CitiesLoaderNotifier, CitiesLoaderState>(
  (ref) {
    return CitiesLoaderNotifier();
  },
);
