import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:trip_planner/features/trip/model/marker_point_model.dart';

class DirectionService {
  static List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  static Future<List<Polyline>> drawRouteBetweenMarkers(
      List<MarkerPoint> markersPoints, String apiKey) async {
    if (markersPoints.length < 2) return [];

    final List<Polyline> newPolylines = [];

    for (int i = 0; i < markersPoints.length - 1; i++) {
      final origin = markersPoints[i].position;
      final destination = markersPoints[i + 1].position;

      final url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ZERO_RESULTS') {
          newPolylines.add(
            Polyline(
              polylineId: PolylineId('route_$i'),
              points: [origin, destination],
              color: Colors.red,
              width: 3,
              patterns: [PatternItem.dash(10), PatternItem.gap(10)],
            ),
          );
          continue;
        }
        final encodedPoints = data['routes'][0]['overview_polyline']['points'];
        final points = decodePolyline(encodedPoints);

        newPolylines.add(
          Polyline(
            polylineId: PolylineId('route_$i'),
            points: points,
            color: Colors.blue,
            width: 5,
          ),
        );
      } else {
        debugPrint('Błąd pobierania trasy $i: ${response.body}');
      }
    }
    return newPolylines;
  }
}
