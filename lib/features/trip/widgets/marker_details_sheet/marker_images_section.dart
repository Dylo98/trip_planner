import 'package:flutter/material.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_add_image_button.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_image_carousel.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_image_picker.dart';

class MarkerImagesSection extends StatelessWidget {
  const MarkerImagesSection({
    super.key,
    required this.marker,
    required this.currentImageIndex,
    required this.onImageIndexChanged,
    required this.onAddImage,
  });

  final MarkerPoint marker;
  final int currentImageIndex;
  final ValueChanged<int> onImageIndexChanged;
  final VoidCallback onAddImage;

  @override
  Widget build(BuildContext context) {
    final imageUrls = marker.imageUrl ?? [];

    if (imageUrls.isEmpty) {
      return _buildEmptyState();
    }

    return _buildImageCarousel(imageUrls);
  }

  Widget _buildEmptyState() {
    return Stack(
      children: [
        EmptyImagePicker(
          onTap: onAddImage,
          selectedImage: null,
        ),
      ],
    );
  }

  Widget _buildImageCarousel(List<String> imageUrls) {
    return Stack(
      children: [
        MarkerImageCarousel(
          imageUrls: imageUrls,
          currentIndex: currentImageIndex,
          onPageChanged: onImageIndexChanged,
        ),
        AddImageButton(onPressed: onAddImage),
      ],
    );
  }
}
