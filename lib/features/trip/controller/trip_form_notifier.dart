import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';

class TripFormNotifier extends StateNotifier<Trip> {
  TripFormNotifier(this._tripService)
      : super(Trip(
          id: '',
          name: '',
          startDate: DateTime.now(),
          endDate: null,
          description: '',
          imageUrl: [],
          tripPhotoUrl: null,
          markerPoints: [],
        ));

  final TripService _tripService;

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setStartDate(DateTime startDate) {
    state = state.copyWith(startDate: startDate);
  }

  void setEndDate(DateTime endDate) {
    state = state.copyWith(endDate: endDate);
  }

  void setImageUrl(List<String> imageUrl) {
    state = state.copyWith(imageUrl: imageUrl);
  }

  void setTripPhotoUrl(String tripPhotoUrl) {
    state = state.copyWith(tripPhotoUrl: tripPhotoUrl);
  }

  Future<void> save(List<MarkerPoint> markers) async {
    final trip = state.copyWith(
      id: const Uuid().v4(),
      startDate: state.startDate,
      markerPoints: markers,
    );

    await _tripService.saveTrip(trip);

    state = Trip(
      id: '',
      name: '',
      startDate: DateTime.now(),
      endDate: null,
      description: '',
      imageUrl: [],
      tripPhotoUrl: null,
      markerPoints: [],
    );
  }
}

final tripFormProvider = StateNotifierProvider<TripFormNotifier, Trip>(
  (ref) => TripFormNotifier(ref.read(tripServiceProvider)),
);
