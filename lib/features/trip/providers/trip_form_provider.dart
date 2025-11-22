import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';

class TripFormState {
  final String name;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final TripType tripType;
  final File? selectedImage;
  final bool isLoading;
  final String? errorMessage;

  const TripFormState({
    this.name = '',
    this.description = '',
    this.startDate,
    this.endDate,
    this.tripType = TripType.planned,
    this.selectedImage,
    this.isLoading = false,
    this.errorMessage,
  });

  TripFormState copyWith({
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    TripType? tripType,
    File? selectedImage,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TripFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      tripType: tripType ?? this.tripType,
      selectedImage: selectedImage ?? this.selectedImage,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  TripFormValidation validate() {
    if (name.trim().isEmpty) {
      return TripFormValidation.error('Nazwa podróży jest wymagana');
    }

    if (name.length > 40) {
      return TripFormValidation.error(
          'Nazwa nie może mieć więcej niż 40 znaków');
    }

    if (startDate == null) {
      return TripFormValidation.error('Data rozpoczęcia jest wymagana');
    }

    if (tripType == TripType.planned && endDate == null) {
      return TripFormValidation.error(
          'Zaplanowana podróż musi mieć datę zakończenia');
    }

    if (endDate != null && endDate!.isBefore(startDate!)) {
      return TripFormValidation.error(
          'Data zakończenia nie może być przed datą rozpoczęcia');
    }

    return TripFormValidation.valid();
  }

  bool get isValid => validate().isValid;
}

class TripFormValidation {
  final bool isValid;
  final String? errorMessage;

  const TripFormValidation.valid()
      : isValid = true,
        errorMessage = null;

  const TripFormValidation.error(this.errorMessage) : isValid = false;
}

class SaveTripResult {
  final bool success;
  final String? errorMessage;

  const SaveTripResult.success()
      : success = true,
        errorMessage = null;

  const SaveTripResult.error(this.errorMessage) : success = false;
}

class TripFormNotifier extends StateNotifier<TripFormState> {
  TripFormNotifier(this._tripService) : super(const TripFormState());

  final TripService _tripService;

  void setName(String name) {
    state = state.copyWith(name: name, errorMessage: null);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setStartDate(DateTime startDate) {
    state = state.copyWith(startDate: startDate, errorMessage: null);
  }

  void setEndDate(DateTime? endDate) {
    state = state.copyWith(endDate: endDate, errorMessage: null);
  }

  void setSelectedImage(File? image) {
    state = state.copyWith(selectedImage: image);
  }

  void setTripType(TripType tripType) {
    state = state.copyWith(
      tripType: tripType,
      endDate: tripType == TripType.ongoing ? null : state.endDate,
      errorMessage: null,
    );
  }

  Future<SaveTripResult> save(List<MarkerPoint> markers) async {
    final validation = state.validate();
    if (!validation.isValid) {
      state = state.copyWith(errorMessage: validation.errorMessage);
      return SaveTripResult.error(validation.errorMessage!);
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final tripId = const Uuid().v4();

      String? tripPhotoUrl;
      if (state.selectedImage != null) {
        tripPhotoUrl = await _tripService.uploadTripImage(
          state.selectedImage!,
          tripId,
        );
      }

      final trip = Trip(
        id: tripId,
        name: state.name.trim(),
        description: state.description.trim(),
        startDate: state.startDate,
        endDate: state.endDate,
        tripPhotoUrl: tripPhotoUrl,
        markerPoints: markers,
        tripType: state.tripType,
        imageUrl: [],
        tripExpenses: [],
      );

      await _tripService.saveTrip(trip);

      state = const TripFormState();

      return const SaveTripResult.success();
    } catch (e) {
      final errorMessage = 'Błąd podczas zapisywania: ${e.toString()}';
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
      return SaveTripResult.error(errorMessage);
    }
  }

  void reset() {
    state = const TripFormState();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final tripFormProvider = StateNotifierProvider<TripFormNotifier, TripFormState>(
  (ref) => TripFormNotifier(ref.read(tripServiceProvider)),
);
