import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner/features/trip/services/google_places/google_places_models.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/providers/nearby_places_provider.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/category_filter_chips.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/places_grid_view.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/loading_state_widget.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/error_state_widget.dart';

class GoogleNearbyPlacesSection extends ConsumerWidget {
  const GoogleNearbyPlacesSection({
    super.key,
    required this.markerPosition,
    required this.onPlaceSelected,
  });

  final LatLng markerPosition;
  final Function(GooglePlace) onPlaceSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesState = ref.watch(nearbyPlacesProvider(markerPosition));
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        _buildHeader(context),
        const SizedBox(height: 12),
        CategoryFilterChips(
          selectedCategory: selectedCategory,
          onCategorySelected: (category) {
            ref.read(selectedCategoryProvider.notifier).state = category;
          },
        ),
        const SizedBox(height: 16),
        placesState.when(
          loading: () => const LoadingStateWidget(),
          error: (error, stack) => ErrorStateWidget(
            error: error,
            onRetry: () => ref.refresh(nearbyPlacesProvider(markerPosition)),
          ),
          data: (data) => _buildContent(context, ref, data),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          const Icon(Icons.explore, size: 24),
          const SizedBox(width: 8),
          Text(
            'Ciekawe miejsca w pobliżu',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    NearbyPlacesData data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlacesGridView(
          places: data.places,
          onPlaceSelected: onPlaceSelected,
        ),
      ],
    );
  }
}
