import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/features/trip/controller/watch_trip_provider.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
  final ImagePicker _picker = ImagePicker();

  Future<void> _onPickImageAndSave() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final image = File(pickedFile.path);
    await ref.read(tripServiceProvider).addImageToMarker(
          tripId: widget.tripId,
          markerId: widget.marker.id,
          image: image,
        );
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
                    GestureDetector(
                      onTap: _onPickImageAndSave,
                      child: Container(
                        height: 300,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          color: Colors.grey[300],
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              )
                            : Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppColors.primaryGradient,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Icon(Icons.add_a_photo,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                      ),
                    )
                  else
                    Stack(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CarouselSlider(
                                options: CarouselOptions(
                                  height: 300,
                                  enableInfiniteScroll: false,
                                  enlargeCenterPage: true,
                                  viewportFraction: 1,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _currentImageIndex = index;
                                    });
                                  },
                                ),
                                items: currentMarker.imageUrl!.map((url) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return ClipRRect(
                                        child: GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => Dialog(
                                                backgroundColor: Colors.black,
                                                child: InteractiveViewer(
                                                  child: Image.network(url,
                                                      fit: BoxFit.contain),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Image.network(url,
                                              fit: BoxFit.cover,
                                              width: double.infinity),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: currentMarker.imageUrl!
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  return Container(
                                    width: 8.0,
                                    height: 8.0,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
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
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: FloatingActionButton(
                            mini: true,
                            onPressed: _onPickImageAndSave,
                            child: const Icon(Icons.add_a_photo),
                          ),
                        ),
                      ],
                    ),
                  Text(widget.marker.name!)
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
