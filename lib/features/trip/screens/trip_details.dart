import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
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
                    Text(widget.trip.name,
                        style: TextStyle(
                          fontSize: 32,
                        )),
                    Text(DateFormat('dd-MM-yyyy')
                        .format(widget.trip.startDate!)),
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
                                showDialog(
                                  context: context,
                                  builder: (_) => Dialog(
                                    backgroundColor: Colors.black,
                                    child: InteractiveViewer(
                                      child: Image.network(imageUrl,
                                          fit: BoxFit.contain),
                                    ),
                                  ),
                                );
                              },
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
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
