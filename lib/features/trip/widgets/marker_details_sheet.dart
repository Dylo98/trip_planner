import 'dart:io';

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
