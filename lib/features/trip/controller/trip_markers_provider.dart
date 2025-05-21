import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'trip_markers_notifier.dart';

final tripMarkersProvider =
    StateNotifierProvider<TripMarkersNotifier, List<MarkerPoint>>(
  (ref) => TripMarkersNotifier(),
);
