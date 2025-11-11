import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/trip/controller/watch_trip_provider.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class TripDetailsScreen extends ConsumerStatefulWidget {
  const TripDetailsScreen({super.key, required this.trip});

  final Trip trip;

  @override
  ConsumerState<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends ConsumerState<TripDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(watchTripProvider(widget.trip.id));
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              widget.trip.tripPhotoUrl != null &&
                      Uri.tryParse(widget.trip.tripPhotoUrl!)
                              ?.hasAbsolutePath ==
                          true
                  ? Image.network(widget.trip.tripPhotoUrl!)
                  : Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Text(
                        'Brak zdjęcia',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(widget.trip.name, style: AppTextStyles.heading1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.trip.startDate != null
                              ? DateFormat('dd-MM-yyyy')
                                  .format(widget.trip.startDate!)
                              : 'Brak daty',
                          style: AppTextStyles.bodyText,
                        ),
                        Icon(Icons.arrow_right),
                        Text(
                            widget.trip.endDate != null
                                ? DateFormat('dd-MM-yyyy')
                                    .format(widget.trip.endDate!)
                                : '...',
                            style: AppTextStyles.bodyText)
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: tripAsync.when(
                  data: (liveTrip) {
                    final markers = liveTrip.markerPoints;
                    final allImages = markers
                        .expand((marker) => marker.imageUrl ?? [])
                        .toList();

                    if (allImages.isEmpty) {
                      return const Text('Brak zdjęć z podróży');
                    }

                    return GridView.custom(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverQuiltedGridDelegate(
                        crossAxisCount: 4,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        repeatPattern: QuiltedGridRepeatPattern.inverted,
                        pattern: const [
                          QuiltedGridTile(2, 2),
                          QuiltedGridTile(1, 1),
                          QuiltedGridTile(1, 1),
                          QuiltedGridTile(1, 2),
                        ],
                      ),
                      childrenDelegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final imageUrl = allImages[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: GestureDetector(
                              onTap: () {
                                showGeneralDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  barrierLabel: "Dismiss",
                                  barrierColor:
                                      Colors.black.withValues(alpha: 0.8),
                                  transitionDuration:
                                      const Duration(milliseconds: 300),
                                  pageBuilder: (_, __, ___) => Center(
                                    child: InteractiveViewer(
                                      child: Image.network(imageUrl,
                                          fit: BoxFit.contain),
                                    ),
                                  ),
                                  transitionBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    return FadeScaleTransition(
                                      animation: animation,
                                      child: child,
                                    );
                                  },
                                );
                              },
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image,
                                      size: 32, color: Colors.grey),
                                ),
                                memCacheWidth: 400,
                                memCacheHeight: 400,
                              ),
                            ),
                          );
                        },
                        childCount: allImages.length,
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Błąd: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
