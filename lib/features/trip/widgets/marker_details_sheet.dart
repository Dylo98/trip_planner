import 'dart:io';
import 'package:uuid/uuid.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:trip_planner/features/trip/controller/watch_trip_provider.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';

import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_add_image_button.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_image_carousel.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_image_picker.dart';

import 'package:trip_planner/features/trip/services/nominatim_search_service.dart';

class MarkerDetailsSheet extends ConsumerStatefulWidget {
  const MarkerDetailsSheet({
    super.key,
    required this.marker,
    required this.tripId,
  });

  final MarkerPoint marker;
  final String tripId;

  @override
  ConsumerState<MarkerDetailsSheet> createState() => _MarkerDetailsSheetState();
}

class _MarkerDetailsSheetState extends ConsumerState<MarkerDetailsSheet> {
  int _currentImageIndex = 0;
  File? _selectedImage;
  final _uuid = const Uuid();
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  List<PlaceSuggestion> _nearbyPlaces = [];
  bool _isLoadingPlaces = true;

  DateTime? _arrivalDateTime;
  DateTime? _departureDateTime;

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return null;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial ?? DateTime.now()),
    );

    if (pickedTime == null) return null;

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  Future<void> _updateMarkerDateTime({
    required DateTime arrival,
    required DateTime departure,
  }) async {
    await ref.read(tripServiceProvider).updateMarkerDates(
          tripId: widget.tripId,
          markerId: widget.marker.id,
          arrival: arrival,
          departure: departure,
        );
  }

  Future<void> _onPickImageAndSave() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final image = File(pickedFile.path);
    await ref.read(tripServiceProvider).addImageToMarker(
          tripId: widget.tripId,
          markerId: widget.marker.id,
          image: image,
          arrival: _arrivalDateTime,
          departure: _departureDateTime,
        );
  }

  Future<void> _deleteMarker() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń punkt podróży'),
        content: const Text('Czy na pewno chcesz usunąć ten punkt podróży?'),
        actions: [
          TextButton(
            child: const Text('Anuluj'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Usuń'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final nav = Navigator.of(context);

      await ref
          .read(tripServiceProvider)
          .deleteMarkerFromTrip(widget.tripId, widget.marker.id);

      nav.pop(true);
    }
  }

  Future<void> _fetchNearbyPlaces() async {
    try {
      final places = await NominatimSearchService.getNearbyPlaces(
        widget.marker.position,
        radiusKm: 2,
      );
      if (mounted) {
        setState(() {
          _nearbyPlaces = places;
          _isLoadingPlaces = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingPlaces = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _arrivalDateTime = widget.marker.arrivalDateTime;
    _departureDateTime = widget.marker.departureDateTime;

    _fetchNearbyPlaces();
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(watchTripProvider(widget.tripId));

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: tripAsync.when(
        data: (trip) {
          final currentMarker = trip.markerPoints.firstWhere(
            (marker) => marker.id == widget.marker.id,
            orElse: () => widget.marker,
          );

          return SingleChildScrollView(
            controller: ModalScrollController.of(context),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                children: [
                  if (currentMarker.imageUrl == null ||
                      currentMarker.imageUrl!.isEmpty)
                    EmptyImagePicker(
                      onTap: _onPickImageAndSave,
                      selectedImage: _selectedImage,
                    )
                  else
                    Stack(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: MarkerImageCarousel(
                            imageUrls: currentMarker.imageUrl!,
                            currentIndex: _currentImageIndex,
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                          ),
                        ),
                        AddImageButton(onPressed: _onPickImageAndSave),
                      ],
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(widget.marker.name!),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            children: [
                              ListTile(
                                title: const Text('Data i godzina przyjazdu'),
                                subtitle: Text(
                                  _arrivalDateTime != null
                                      ? '${_arrivalDateTime!.day}.${_arrivalDateTime!.month}.${_arrivalDateTime!.year} '
                                          '${_arrivalDateTime!.hour.toString().padLeft(2, '0')}:${_arrivalDateTime!.minute.toString().padLeft(2, '0')}'
                                      : 'Wybierz datę i godzinę',
                                ),
                                trailing: const Icon(Icons.access_time),
                                onTap: () async {
                                  final result =
                                      await _pickDateTime(_arrivalDateTime);
                                  if (result != null) {
                                    setState(() {
                                      _arrivalDateTime = result;
                                    });

                                    if (_departureDateTime != null) {
                                      await _updateMarkerDateTime(
                                        arrival: result,
                                        departure: _departureDateTime!,
                                      );
                                    }
                                  }
                                },
                              ),
                              ListTile(
                                title: const Text('Data i godzina odjazdu'),
                                subtitle: Text(
                                  _departureDateTime != null
                                      ? '${_departureDateTime!.day}.${_departureDateTime!.month}.${_departureDateTime!.year} '
                                          '${_departureDateTime!.hour.toString().padLeft(2, '0')}:${_departureDateTime!.minute.toString().padLeft(2, '0')}'
                                      : 'Wybierz datę i godzinę',
                                ),
                                trailing: const Icon(Icons.access_time),
                                onTap: () async {
                                  final result =
                                      await _pickDateTime(_departureDateTime);
                                  if (result != null) {
                                    setState(() {
                                      _departureDateTime = result;
                                    });

                                    if (_arrivalDateTime != null) {
                                      await _updateMarkerDateTime(
                                        arrival: _arrivalDateTime!,
                                        departure: result,
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        if (_isLoadingPlaces)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          )
                        else if (_nearbyPlaces.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'Ciekawe miejsca w pobliżu:',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  height: 200,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _nearbyPlaces.length,
                                    itemBuilder: (context, index) {
                                      final place = _nearbyPlaces[index];
                                      return GestureDetector(
                                        onTap: () async {
                                          final newMarker = MarkerPoint(
                                            id: _uuid.v4(),
                                            name: place.name,
                                            position: place.location,
                                            arrivalDateTime: null,
                                            departureDateTime: null,
                                            imageUrl: [],
                                            transportMode: 'walk',
                                          );

                                          await ref
                                              .read(tripServiceProvider)
                                              .addMarkerToTrip(
                                                  widget.tripId, newMarker);
                                          if (mounted) {
                                            Navigator.of(context).pop();
                                          }
                                        },
                                        child: Container(
                                          width: 200,
                                          margin: const EdgeInsets.all(8),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.shade300,
                                                blurRadius: 5,
                                                offset: const Offset(2, 2),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (place.photoReference != null)
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.network(
                                                    place.photoReference!,
                                                    height: 100,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Container(
                                                        height: 100,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .grey.shade200,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.place,
                                                            size: 48,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    loadingBuilder: (context,
                                                        child,
                                                        loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) {
                                                        return child;
                                                      }
                                                      return Container(
                                                        height: 100,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .grey.shade200,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: const Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )
                                              else
                                                Container(
                                                  height: 100,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.place,
                                                      size: 48,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              const SizedBox(height: 4),
                                              Text(
                                                place.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (place.address != null)
                                                Text(
                                                  place.address!,
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red, size: 32),
                            tooltip: 'Usuń punkt podróży',
                            onPressed: _deleteMarker,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Błąd: $e')),
      ),
    );
  }
}
