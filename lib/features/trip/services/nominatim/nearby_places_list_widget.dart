import 'package:flutter/material.dart';
import 'package:trip_planner/features/trip/services/nominatim/nominatim.dart';
import 'place_details_dialog.dart';

/// Widget wyświetlający listę ciekawych miejsc w pobliżu
///
/// UŻYCIE:
/// 1. Pobierz bounds z mapy: await mapController.getVisibleRegion()
/// 2. Wywołaj getNearbyPlacesInBounds(bounds)
/// 3. Wyświetl NearbyPlacesList z pobranymi miejscami
class NearbyPlacesList extends StatelessWidget {
  final List<PlaceSuggestion> places;
  final Function(PlaceSuggestion) onPlaceSelected;

  const NearbyPlacesList({
    super.key,
    required this.places,
    required this.onPlaceSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      itemCount: places.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final place = places[index];
        return _buildPlaceCard(context, place);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Brak ciekawych miejsc w tym obszarze',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Spróbuj przesunąć mapę lub oddal widok',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(BuildContext context, PlaceSuggestion place) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: InkWell(
        onTap: () => _handlePlaceTap(context, place),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildPlaceImage(place),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          place.categoryEmoji,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          place.category.displayName,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade700,
                                  ),
                        ),
                      ],
                    ),
                    if (place.details?.openingHours != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              place.details!.openingHours!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceImage(PlaceSuggestion place) {
    if (place.hasPhoto) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          place.photoReference!,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildEmojiPlaceholder(place);
          },
        ),
      );
    } else {
      return _buildEmojiPlaceholder(place);
    }
  }

  Widget _buildEmojiPlaceholder(PlaceSuggestion place) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade300,
            Colors.purple.shade300,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          place.categoryEmoji,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }

  Future<void> _handlePlaceTap(
      BuildContext context, PlaceSuggestion place) async {
    final shouldAdd = await showPlaceDetailsDialog(context, place);

    if (shouldAdd) {
      onPlaceSelected(place);
    }
  }
}
