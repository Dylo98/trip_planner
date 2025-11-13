import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/controller/watch_trip_provider.dart';
import 'package:trip_planner/features/trip/controller/trip_markers_provider.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_details_state.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_dates_section.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_transport_section.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_expense_section.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_nearby_places_section.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_add_image_button.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_image_carousel.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_image_picker.dart';
import 'package:trip_planner/features/trip/services/nominatim/nominatim.dart';
import 'package:trip_planner/features/trip/services/nominatim/place_details_dialog.dart';
import 'package:trip_planner/features/trip/widgets/select_transport.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_description_section.dart';

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

  int _currentImageIndex = 0;
  List<PlaceSuggestion> _nearbyPlaces = [];
  bool _isLoadingPlaces = true;

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
    _fetchNearbyPlaces();
  }

  Future<void> _fetchNearbyPlaces() async {
    try {
      final places = await NominatimNearbyService.getNearbyPlaces(
        widget.marker.position,
        radiusKm: 2,
      );
      if (!mounted) return;
      setState(() {
        _nearbyPlaces = places;
        _isLoadingPlaces = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingPlaces = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_state.isNewTrip) {
      final tripAsync = ref.watch(watchTripProvider(widget.tripId!));
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: tripAsync.when(
          data: (trip) {
            final liveMarker = trip.markerPoints.firstWhere(
              (m) => m.id == _state.currentMarker.id,
              orElse: () => _state.currentMarker,
            );
            return _buildContent(liveMarker);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Błąd: $e')),
        ),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: _buildContent(_state.currentMarker),
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayMarker.name ?? 'Bez nazwy',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  MarkerDatesSection(
                    state: _state,
                    onDatesUpdated: () => setState(() {}),
                  ),
                  const Divider(height: 32),
                  MarkerTransportSection(
                    transportMode: displayMarker.transportMode,
                    onTransportChanged: (mode) async {
                      setState(() {});
                    },
                  ),
                  MarkerExpenseSection(
                    initialExpense: displayMarker.expense,
                    onExpenseChanged: (expense) async {
                      await _state.updateExpense(expense, setState);
                    },
                  ),
                  MarkerDescriptionSection(
                    initialDescription: displayMarker.description,
                    onDescriptionChanged: (description) async {
                      await _state.updateDescription(description, setState);
                    },
                  ),
                  MarkerNearbyPlacesSection(
                    places: _nearbyPlaces,
                    isLoading: _isLoadingPlaces,
                    onPlaceSelected: (place) async {
                      final shouldAdd =
                          await showPlaceDetailsDialog(context, place);
                      if (!shouldAdd || !mounted) return;
                      final transport = await selectTransport(context);
                      if (transport == null || !mounted) return;

                      final newMarker = MarkerPoint(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        position: place.location,
                        name: place.name,
                        description: place.address,
                        transportMode: transport,
                        imageUrl: null,
                        arrivalDateTime: null,
                        departureDateTime: null,
                        expense: null,
                      );

                      if (_state.isNewTrip) {
                        ref
                            .read(tripMarkersProvider.notifier)
                            .addMarker(newMarker);
                      } else {
                        await ref.read(tripServiceProvider).addMarkerToTrip(
                              widget.tripId!,
                              newMarker,
                            );

                        if (mounted) {
                          Navigator.pop(context);
                        }
                      }

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Dodano: ${place.name} (${_getTransportName(transport)})',
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red, size: 32),
                        tooltip: 'Usuń punkt podróży',
                        onPressed: _state.deleteMarker,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection(MarkerPoint marker) {
    final imageUrls = marker.imageUrl ?? [];

    if (imageUrls.isEmpty) {
      return Stack(
        children: [
          EmptyImagePicker(
            onTap: () => _state.pickAndAddImage(setState),
            selectedImage: null,
          ),
        ],
      );
    }

    return Stack(
      children: [
        MarkerImageCarousel(
          imageUrls: imageUrls,
          currentIndex: _currentImageIndex,
          onPageChanged: (index) => setState(() => _currentImageIndex = index),
        ),
        AddImageButton(
          onPressed: () => _state.pickAndAddImage(setState),
        ),
      ],
    );
  }

  String _getTransportName(String mode) {
    switch (mode) {
      case 'plane':
        return 'Samolot';
      case 'walk':
        return 'Pieszo';
      case 'car':
        return 'Samochód';
      default:
        return 'Inne';
    }
  }
}
