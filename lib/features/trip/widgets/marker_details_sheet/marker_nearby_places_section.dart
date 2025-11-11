// lib/features/trip/widgets/marker_details_sheet/marker_nearby_places_section.dart
import 'package:flutter/material.dart';
import 'package:trip_planner/features/trip/services/nominatim_search_service.dart';

class MarkerNearbyPlacesSection extends StatelessWidget {
  const MarkerNearbyPlacesSection({
    super.key,
    required this.places,
    required this.isLoading,
    required this.onPlaceSelected,
  });

  final List<PlaceSuggestion> places;
  final bool isLoading;
  final Function(PlaceSuggestion) onPlaceSelected;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (places.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Ciekawe miejsca w pobliżu',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return _buildPlaceCard(place);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceCard(PlaceSuggestion place) {
    return GestureDetector(
      onTap: () => onPlaceSelected(place),
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
            _buildPlaceImage(place),
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
  }

  Widget _buildPlaceImage(PlaceSuggestion place) {
    if (place.photoReference != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          place.photoReference!,
          height: 100,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => _buildPlaceholder(),
          loadingBuilder: (context, child, prog) {
            if (prog == null) return child;
            return Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.place, size: 48, color: Colors.grey),
      ),
    );
  }
}
