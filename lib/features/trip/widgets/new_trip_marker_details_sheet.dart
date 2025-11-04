import 'dart:io';
import 'package:uuid/uuid.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:intl/intl.dart';

import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/controller/trip_markers_provider.dart';

import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_add_image_button.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_image_carousel.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_image_picker.dart';
import 'package:trip_planner/features/trip/widgets/select_transport.dart';

import 'package:trip_planner/features/trip/services/nominatim_search_service.dart';

class NewTripMarkerDetailsSheet extends ConsumerStatefulWidget {
  const NewTripMarkerDetailsSheet({
    super.key,
    required this.marker,
  });

  final MarkerPoint marker;

  @override
  ConsumerState<NewTripMarkerDetailsSheet> createState() =>
      _NewTripMarkerDetailsSheetState();
}

class _NewTripMarkerDetailsSheetState
    extends ConsumerState<NewTripMarkerDetailsSheet> {
  int _currentImageIndex = 0;
  final List<File> _localImages = [];
  final _uuid = const Uuid();
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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

  Future<void> _onPickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final image = File(pickedFile.path);
    setState(() {
      _localImages.add(image);
    });
  }

  void _updateMarkerInProvider() {
    final updatedMarker = widget.marker.copyWith(
      name: _nameController.text.isNotEmpty
          ? _nameController.text
          : widget.marker.name,
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : widget.marker.description,
      arrivalDateTime: _arrivalDateTime,
      departureDateTime: _departureDateTime,
    );

    ref.read(tripMarkersProvider.notifier).updateMarker(
          widget.marker.id,
          updatedMarker,
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
      ref.read(tripMarkersProvider.notifier).removeMarker(widget.marker.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
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
    _nameController.text = widget.marker.name ?? '';
    _descriptionController.text = widget.marker.description ?? '';
    _arrivalDateTime = widget.marker.arrivalDateTime;
    _departureDateTime = widget.marker.departureDateTime;

    _fetchNearbyPlaces();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
              if (_localImages.isEmpty)
                Stack(
                  children: [
                    EmptyImagePicker(
                      onTap: _onPickImage,
                      selectedImage: null,
                    ),
                    AddImageButton(onPressed: _onPickImage),
                  ],
                )
              else
                Stack(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 300,
                          child: PageView.builder(
                            itemCount: _localImages.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Image.file(
                                _localImages[index],
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _localImages.asMap().entries.map((entry) {
                            return Container(
                              width: 8.0,
                              height: 8.0,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentImageIndex == entry.key
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    AddImageButton(onPressed: _onPickImage),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nazwa punktu',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _updateMarkerInProvider(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Opis',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onChanged: (_) => _updateMarkerInProvider(),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.flight_land),
                        title: const Text('Data przyjazdu'),
                        subtitle: Text(
                          _arrivalDateTime != null
                              ? DateFormat('dd.MM.yyyy HH:mm')
                                  .format(_arrivalDateTime!)
                              : 'Nie ustawiono',
                        ),
                        trailing: const Icon(Icons.edit),
                        onTap: () async {
                          final picked = await _pickDateTime(_arrivalDateTime);
                          if (picked != null) {
                            setState(() {
                              _arrivalDateTime = picked;
                            });
                            _updateMarkerInProvider();
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.flight_takeoff),
                        title: const Text('Data wyjazdu'),
                        subtitle: Text(
                          _departureDateTime != null
                              ? DateFormat('dd.MM.yyyy HH:mm')
                                  .format(_departureDateTime!)
                              : 'Nie ustawiono',
                        ),
                        trailing: const Icon(Icons.edit),
                        onTap: () async {
                          final picked =
                              await _pickDateTime(_departureDateTime);
                          if (picked != null) {
                            setState(() {
                              _departureDateTime = picked;
                            });
                            _updateMarkerInProvider();
                          }
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
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
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
                                      final transportMode =
                                          await selectTransport(context);
                                      if (transportMode == null) return;

                                      ref
                                          .read(tripMarkersProvider.notifier)
                                          .updateMarkerTransport(
                                            widget.marker.id,
                                            transportMode,
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

                                      ref
                                          .read(tripMarkersProvider.notifier)
                                          .addMarker(newMarker);

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
                                                      color:
                                                          Colors.grey.shade200,
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
                                                  );
                                                },
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }
                                                  return Container(
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade200,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
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
                                              style:
                                                  const TextStyle(fontSize: 12),
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
                            icon: const Icon(Icons.delete,
                                color: Colors.red, size: 32),
                            tooltip: 'Usuń punkt podróży',
                            onPressed: _deleteMarker,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
