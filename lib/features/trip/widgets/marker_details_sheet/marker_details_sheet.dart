import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/providers/watch_trip_provider.dart';
import 'package:trip_planner/features/trip/services/google_places/google_places_service.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_details_state.dart';
import 'package:trip_planner/features/trip/controllers/google_place_addition_controller.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_details_content.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_images_section.dart';

class MarkerDetailsSheet extends ConsumerStatefulWidget {
  const MarkerDetailsSheet({
    super.key,
    required this.marker,
    this.tripId,
    this.onUpdate,
  });

  final MarkerPoint marker;
  final String? tripId;
  final void Function(MarkerPoint)? onUpdate;

  @override
  ConsumerState<MarkerDetailsSheet> createState() => _MarkerDetailsSheetState();
}

class _MarkerDetailsSheetState extends ConsumerState<MarkerDetailsSheet> {
  late final MarkerDetailsState _state;
  late final GooglePlaceAdditionController _placeController;

  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _state = MarkerDetailsState(
      ref: ref,
      context: context,
      marker: widget.marker,
      tripId: widget.tripId,
      onUpdate: widget.onUpdate,
    );

    _placeController = GooglePlaceAdditionController(
      ref: ref,
      context: context,
      tripId: widget.tripId,
    );

    GooglePlacesService.loadDailyStats();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_state.isNewTrip) {
      return _buildContent(_state.currentMarker);
    }

    final tripAsync = ref.watch(watchTripProvider(widget.tripId!));
    return tripAsync.when(
      data: (trip) {
        final liveMarker = trip.markerPoints.firstWhere(
          (m) => m.id == _state.currentMarker.id,
          orElse: () => _state.currentMarker,
        );
        return _buildContent(liveMarker);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Błąd: $e')),
    );
  }

  Widget _buildContent(MarkerPoint displayMarker) {
    return SingleChildScrollView(
      controller: ModalScrollController.of(context),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          children: [
            _buildImagesSection(displayMarker),
            _buildDetailsSection(displayMarker),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection(MarkerPoint marker) {
    return MarkerImagesSection(
      marker: marker,
      currentImageIndex: _currentImageIndex,
      onImageIndexChanged: (index) =>
          setState(() => _currentImageIndex = index),
      onAddImage: () => _state.pickAndAddImage(setState),
    );
  }

  Widget _buildDetailsSection(MarkerPoint marker) {
    return MarkerDetailsContent(
      marker: marker,
      onDescriptionChanged: (description) async {
        await _state.updateDescription(description, setState);
      },
      onNameChanged: (name) async {
        await _state.updateName(name, setState);
      },
      onPlaceSelected: (place) async {
        await _placeController.handlePlaceSelection(place);
      },
      onDelete: _state.deleteMarker,
    );
  }
}
