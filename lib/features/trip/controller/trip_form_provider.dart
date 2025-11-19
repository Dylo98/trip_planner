import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';

class TripFormNotifier extends StateNotifier<Trip> {
  TripFormNotifier(this._tripService)
      : super(Trip(
          id: '',
          name: '',
          startDate: null,
          endDate: null,
          description: '',
          imageUrl: [],
          tripPhotoUrl: null,
          markerPoints: [],
          tripType: TripType.planned,
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

  void setEndDate(DateTime? endDate) {
    state = state.copyWith(endDate: endDate);
  }

  void setImageUrl(List<String> imageUrl) {
    state = state.copyWith(imageUrl: imageUrl);
  }

  void setTripPhotoUrl(String? tripPhotoUrl) {
    state = state.copyWith(tripPhotoUrl: tripPhotoUrl);
  }

  void setTripType(TripType tripType) {
    state = state.copyWith(tripType: tripType);
    if (tripType == TripType.ongoing) {
      state = state.copyWith(endDate: null);
    }
  }

  Future<void> save(File? image, List<MarkerPoint> markers) async {
    if (state.name.trim().isEmpty) {
      throw Exception('Nazwa podróży jest wymagana');
    }

    if (state.startDate == null) {
      throw Exception('Data rozpoczęcia jest wymagana');
    }

    if (state.tripType == TripType.planned && state.endDate == null) {
      throw Exception('Zaplanowana podróż musi mieć datę zakończenia');
    }

    if (state.endDate != null && state.endDate!.isBefore(state.startDate!)) {
      throw Exception('Data zakończenia nie może być przed datą rozpoczęcia');
    }

    final tripId = const Uuid().v4();

    String? tripPhotoUrl;
    if (image != null) {
      tripPhotoUrl = await _tripService.uploadTripImage(image, tripId);
    }

    final trip = state.copyWith(
      id: tripId,
      startDate: state.startDate,
      markerPoints: markers,
      tripPhotoUrl: tripPhotoUrl,
      tripType: state.tripType,
    );

    await _tripService.saveTrip(trip);

    state = Trip(
      id: '',
      name: '',
      startDate: null,
      endDate: null,
      description: '',
      imageUrl: [],
      tripPhotoUrl: null,
      markerPoints: [],
      tripType: TripType.planned,
    );
  }
}

final tripFormProvider = StateNotifierProvider<TripFormNotifier, Trip>(
  (ref) => TripFormNotifier(ref.read(tripServiceProvider)),
);
