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
import 'package:trip_planner/features/trip/widgets/select_transport.dart';

import 'package:trip_planner/features/trip/services/nominatim_search_service.dart';

import 'package:trip_planner/core/utils/action_lock.dart';
import 'package:trip_planner/core/utils/debouncer.dart';

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
  final TextEditingController _expenseController = TextEditingController();

  final _pickImageLock = ActionLock();
  final _deleteLock = ActionLock();
  final _updateDatesLock = ActionLock();
  final _addNearbyLock = ActionLock();

  final _expenseDebouncer = Debouncer(milliseconds: 600);

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

  Future<void> _onPickImageAndSave() async {
    await _pickImageLock.run(() async {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final image = File(pickedFile.path);
      if (mounted) {
        setState(() {
          _selectedImage = image;
        });
      }

      await ref.read(tripServiceProvider).addImageToMarker(
            tripId: widget.tripId,
            markerId: widget.marker.id,
            image: image,
            arrival: _arrivalDateTime,
            departure: _departureDateTime,
          );
    });
  }

  Future<void> _deleteMarker() async {
    await _deleteLock.run(() async {
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
        if (nav.mounted) {
          nav.pop(true);
        }
      }
    });
  }

  Future<void> _fetchNearbyPlaces() async {
    try {
      final places = await NominatimSearchService.getNearbyPlaces(
        widget.marker.position,
        radiusKm: 2,
      );
      if (!mounted) return;
      setState(() {
        _nearbyPlaces = places;
        _isLoadingPlaces = false;
      });
    } catch (e) {
      if (!mounted) return;
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
    _expenseController.text = widget.marker.expense?.toStringAsFixed(2) ?? '';

    _fetchNearbyPlaces();
  }

  @override
  void dispose() {
    _expenseController.dispose();
    _expenseDebouncer.dispose();
    super.dispose();
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
                    Stack(
                      children: [
                        EmptyImagePicker(
                          onTap: _onPickImageAndSave,
                          selectedImage: _selectedImage,
                        ),
                        AddImageButton(onPressed: _onPickImageAndSave),
                      ],
                    )
                  else
                    Stack(
                      children: [
                        MarkerImageCarousel(
                          imageUrls: currentMarker.imageUrl!,
                          currentIndex: _currentImageIndex,
                          onPageChanged: (index) {
                            if (!mounted) return;
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                        ),
                        AddImageButton(onPressed: _onPickImageAndSave),
                      ],
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentMarker.name ?? 'Bez nazwy',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (currentMarker.description != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              currentMarker.description!,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        const Divider(height: 32),
                        ListTile(
                          leading: const Icon(Icons.flight_land),
                          title: const Text('Data przyjazdu'),
                          subtitle: Text(
                            _arrivalDateTime != null
                                ? _arrivalDateTime!
                                    .toLocal()
                                    .toString()
                                    .substring(0, 16)
                                : 'Nie ustawiono',
                          ),
                          trailing: const Icon(Icons.edit),
                          onTap: () async {
                            await _updateDatesLock.run(() async {
                              final picked =
                                  await _pickDateTime(_arrivalDateTime);
                              if (picked == null) return;

                              if (mounted) {
                                setState(() {
                                  _arrivalDateTime = picked;
                                });
                              }

                              await ref
                                  .read(tripServiceProvider)
                                  .updateMarkerDates(
                                    tripId: widget.tripId,
                                    markerId: widget.marker.id,
                                    arrival: picked,
                                    departure: _departureDateTime ?? picked,
                                  );
                            });
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.flight_takeoff),
                          title: const Text('Data wyjazdu'),
                          subtitle: Text(
                            _departureDateTime != null
                                ? _departureDateTime!
                                    .toLocal()
                                    .toString()
                                    .substring(0, 16)
                                : 'Nie ustawiono',
                          ),
                          trailing: const Icon(Icons.edit),
                          onTap: () async {
                            await _updateDatesLock.run(() async {
                              final picked =
                                  await _pickDateTime(_departureDateTime);
                              if (picked == null) return;

                              if (mounted) {
                                setState(() {
                                  _departureDateTime = picked;
                                });
                              }

                              await ref
                                  .read(tripServiceProvider)
                                  .updateMarkerDates(
                                    tripId: widget.tripId,
                                    markerId: widget.marker.id,
                                    arrival: _arrivalDateTime ?? picked,
                                    departure: picked,
                                  );
                            });
                          },
                        ),
                        const Divider(height: 32),
                        Padding(
                          padding: const EdgeInsets.all(0),
                          child: TextFormField(
                            controller: _expenseController,
                            decoration: const InputDecoration(
                              labelText: 'Wydatek (PLN)',
                              hintText: 'Wprowadź kwotę',
                              prefixIcon: Icon(Icons.attach_money),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (value) {
                              _expenseDebouncer.run(() async {
                                final parsed = double.tryParse(
                                  _expenseController.text.replaceAll(',', '.'),
                                );
                                if (parsed != null) {
                                  await ref
                                      .read(tripServiceProvider)
                                      .updateMarkerExpense(
                                        tripId: widget.tripId,
                                        markerId: widget.marker.id,
                                        expense: parsed,
                                      );
                                }
                              });
                            },
                          ),
                        ),
                        const Divider(height: 32),
                        if (_isLoadingPlaces)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_nearbyPlaces.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Ciekawe miejsca w pobliżu',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                        await _addNearbyLock.run(() async {
                                          final transportMode =
                                              await selectTransport(context);
                                          if (transportMode == null) return;

                                          await ref
                                              .read(tripServiceProvider)
                                              .updateMarkerTransportMode(
                                                tripId: widget.tripId,
                                                markerId: widget.marker.id,
                                                transportMode: transportMode,
                                              );

                                          final newMarker = MarkerPoint(
                                            id: _uuid.v4(),
                                            name: place.name,
                                            position: place.location,
                                            arrivalDateTime: null,
                                            departureDateTime: null,
                                            imageUrl: [],
                                            transportMode: 'other',
                                          );

                                          await ref
                                              .read(tripServiceProvider)
                                              .addMarkerToTrip(
                                                  widget.tripId, newMarker);
                                          if (mounted) {
                                            Navigator.of(context).pop();
                                          }
                                        });
                                      },
                                      child: Container(
                                        width: 200,
                                        margin: const EdgeInsets.all(8),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
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
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      height: 100,
                                                      decoration: BoxDecoration(
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
                                                      child, loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    }
                                                    return Container(
                                                      height: 100,
                                                      decoration: BoxDecoration(
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
                                                      BorderRadius.circular(8),
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
                                                  fontSize: 12,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
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
