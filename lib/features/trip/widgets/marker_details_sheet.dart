import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:uuid/uuid.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/controller/watch_trip_provider.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';
import 'package:trip_planner/features/trip/controller/trip_markers_provider.dart';
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
  final _uuid = const Uuid();
  final ImagePicker _picker = ImagePicker();

  late MarkerPoint _currentMarker;
  int _currentImageIndex = 0;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _expenseController = TextEditingController();

  DateTime? _arrivalDateTime;
  DateTime? _departureDateTime;

  List<PlaceSuggestion> _nearbyPlaces = [];
  bool _isLoadingPlaces = true;

  final _pickImageLock = ActionLock();
  final _deleteLock = ActionLock();
  final _updateDatesLock = ActionLock();
  final _addNearbyLock = ActionLock();
  final _expenseDebouncer = Debouncer(milliseconds: 600);

  bool get isNewTrip => widget.tripId == null;

  @override
  void initState() {
    super.initState();
    _currentMarker = widget.marker;
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

  String _formatDT(DateTime? dt) {
    if (dt == null) return 'Nie ustawiono';
    return DateFormat('dd.MM.yyyy HH:mm').format(dt.toLocal());
  }

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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingPlaces = false;
      });
    }
  }

  Future<void> _updateMarkerDates({
    required DateTime arrival,
    required DateTime departure,
  }) async {
    if (isNewTrip) {
      final updated = _currentMarker.copyWith(
        arrivalDateTime: arrival,
        departureDateTime: departure,
      );
      setState(() => _currentMarker = updated);
      widget.onUpdate?.call(updated);

      ref.read(tripMarkersProvider.notifier).updateMarker(
            _currentMarker.id,
            updated,
          );
    } else {
      await ref.read(tripServiceProvider).updateMarkerDates(
            tripId: widget.tripId!,
            markerId: _currentMarker.id,
            arrival: arrival,
            departure: departure,
          );
    }
  }

  Future<void> _updateExpense(double expense) async {
    if (isNewTrip) {
      final updated = _currentMarker.copyWith(expense: expense);
      setState(() => _currentMarker = updated);
      widget.onUpdate?.call(updated);

      ref.read(tripMarkersProvider.notifier).updateMarker(
            _currentMarker.id,
            updated,
          );
    } else {
      await ref.read(tripServiceProvider).updateMarkerExpense(
            tripId: widget.tripId!,
            markerId: _currentMarker.id,
            expense: expense,
          );
    }
  }

  Future<void> _pickAndAddImage() async {
    await _pickImageLock.run(() async {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final file = File(pickedFile.path);

      if (isNewTrip) {
        final newUrls = List<String>.from(_currentMarker.imageUrl ?? []);
        newUrls.add(file.path);

        final updated = _currentMarker.copyWith(imageUrl: newUrls);
        setState(() => _currentMarker = updated);
        widget.onUpdate?.call(updated);

        ref.read(tripMarkersProvider.notifier).updateMarker(
              _currentMarker.id,
              updated,
            );
      } else {
        await ref.read(tripServiceProvider).addImageToMarker(
              tripId: widget.tripId!,
              markerId: _currentMarker.id,
              image: file,
              arrival: _arrivalDateTime,
              departure: _departureDateTime,
            );
      }
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
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Anuluj'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Usuń'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        if (isNewTrip) {
          ref
              .read(tripMarkersProvider.notifier)
              .removeMarker(_currentMarker.id);
          if (mounted) Navigator.of(context).pop();
        } else {
          final nav = Navigator.of(context);
          await ref
              .read(tripServiceProvider)
              .deleteMarkerFromTrip(widget.tripId!, _currentMarker.id);
          if (nav.mounted) nav.pop(true);
        }
      }
    });
  }

  Future<void> _addNearbyPlace(PlaceSuggestion place) async {
    await _addNearbyLock.run(() async {
      final transportMode = await selectTransport(context);
      if (transportMode == null) return;

      if (isNewTrip) {
        ref.read(tripMarkersProvider.notifier).updateMarkerTransport(
              _currentMarker.id,
              transportMode,
            );
      } else {
        await ref.read(tripServiceProvider).updateMarkerTransportMode(
              tripId: widget.tripId!,
              markerId: _currentMarker.id,
              transportMode: transportMode,
            );
      }

      final newMarker = MarkerPoint(
        id: _uuid.v4(),
        name: place.name,
        position: place.location,
        arrivalDateTime: null,
        departureDateTime: null,
        imageUrl: const [],
        transportMode: 'other',
      );

      if (isNewTrip) {
        ref.read(tripMarkersProvider.notifier).addMarker(newMarker);
        if (mounted) Navigator.of(context).pop();
      } else {
        await ref
            .read(tripServiceProvider)
            .addMarkerToTrip(widget.tripId!, newMarker);
        if (mounted) Navigator.of(context).pop();
      }
    });
  }

  Widget _buildImagesSection({
    required MarkerPoint markerForUi,
  }) {
    final urls = markerForUi.imageUrl ?? const [];

    if (urls.isEmpty) {
      return Stack(
        children: [
          EmptyImagePicker(
            onTap: _pickAndAddImage,
            selectedImage: null,
          ),
          AddImageButton(onPressed: _pickAndAddImage),
        ],
      );
    }

    final hasAnyLocal = isNewTrip && urls.any((p) => File(p).existsSync());

    if (hasAnyLocal && isNewTrip) {
      return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: urls.map((p) {
                final f = File(p);
                if (f.existsSync()) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      f,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  );
                }
                return Container(
                  width: 120,
                  height: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.image, size: 32),
                );
              }).toList(),
            ),
          ),
          AddImageButton(onPressed: _pickAndAddImage),
        ],
      );
    }

    return Stack(
      children: [
        MarkerImageCarousel(
          imageUrls: urls,
          currentIndex: _currentImageIndex,
          onPageChanged: (idx) {
            if (!mounted) return;
            setState(() => _currentImageIndex = idx);
          },
        ),
        AddImageButton(onPressed: _pickAndAddImage),
      ],
    );
  }

  Widget _buildCoreContent(MarkerPoint markerForUi) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              markerForUi.name ?? 'Bez nazwy',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (markerForUi.description != null &&
                markerForUi.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  markerForUi.description!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.flight_land),
              title: const Text('Data przyjazdu'),
              subtitle: Text(_formatDT(_arrivalDateTime)),
              trailing: const Icon(Icons.edit),
              onTap: () async {
                await _updateDatesLock.run(() async {
                  final picked = await _pickDateTime(_arrivalDateTime);
                  if (picked == null) return;

                  setState(() => _arrivalDateTime = picked);
                  await _updateMarkerDates(
                    arrival: picked,
                    departure: _departureDateTime ?? picked,
                  );
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.flight_takeoff),
              title: const Text('Data wyjazdu'),
              subtitle: Text(_formatDT(_departureDateTime)),
              trailing: const Icon(Icons.edit),
              onTap: () async {
                await _updateDatesLock.run(() async {
                  final picked = await _pickDateTime(_departureDateTime);
                  if (picked == null) return;

                  setState(() => _departureDateTime = picked);
                  await _updateMarkerDates(
                    arrival: _arrivalDateTime ?? picked,
                    departure: picked,
                  );
                });
              },
            ),
            const Divider(height: 32),
            TextFormField(
              controller: _expenseController,
              decoration: const InputDecoration(
                labelText: 'Wydatek (PLN)',
                hintText: 'Wprowadź kwotę',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) {
                _expenseDebouncer.run(() async {
                  final parsed = double.tryParse(
                    _expenseController.text.replaceAll(',', '.'),
                  );
                  if (parsed != null) {
                    await _updateExpense(parsed);
                  }
                });
              },
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          onTap: () => _addNearbyPlace(place),
                          child: Container(
                            width: 200,
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 5,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (place.photoReference != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      place.photoReference!,
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) {
                                        return Container(
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Center(
                                            child: Icon(Icons.place,
                                                size: 48, color: Colors.grey),
                                          ),
                                        );
                                      },
                                      loadingBuilder: (context, child, prog) {
                                        if (prog == null) return child;
                                        return Container(
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Center(
                                            child: CircularProgressIndicator(),
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
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.place,
                                          size: 48, color: Colors.grey),
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
                                    style: const TextStyle(fontSize: 12),
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
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 32),
                  tooltip: 'Usuń punkt podróży',
                  onPressed: _deleteMarker,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isNewTrip) {
      final tripAsync = ref.watch(watchTripProvider(widget.tripId!));
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: tripAsync.when(
          data: (trip) {
            final liveMarker = trip.markerPoints.firstWhere(
              (m) => m.id == _currentMarker.id,
              orElse: () => _currentMarker,
            );
            return SingleChildScrollView(
              controller: ModalScrollController.of(context),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  children: [
                    _buildImagesSection(markerForUi: liveMarker),
                    _buildCoreContent(liveMarker),
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

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
              _buildImagesSection(markerForUi: _currentMarker),
              _buildCoreContent(_currentMarker),
            ],
          ),
        ),
      ),
    );
  }
}
