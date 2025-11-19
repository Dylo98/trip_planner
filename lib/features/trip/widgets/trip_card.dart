import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trip_planner/core/utils/action_lock.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/screens/main_trip_details.dart';
import 'package:trip_planner/features/trip/widgets/trip_sorting_helper.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';

class TripCard extends ConsumerWidget {
  const TripCard({
    super.key,
    required this.trip,
    required this.openTripLock,
  });

  final Trip trip;
  final ActionLock openTripLock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String urlImage = trip.tripPhotoUrl ?? '';
    final String tripName = trip.name ?? '';
    final String formattedStartDate = trip.startDate != null
        ? DateFormat('dd-MM-yyyy').format(trip.startDate!)
        : 'Brak daty';
    final totalBudget = TripSortingHelper.calculateTotalBudget(trip);

    return Dismissible(
      key: Key('trip_${trip.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 32),
            SizedBox(height: 4),
            Text(
              'Usuń',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Usuń podróż'),
            content: Text(
              'Czy na pewno chcesz usunąć podróż "$tripName"?\n\n'
              'Ta akcja jest nieodwracalna i usunie wszystkie zdjęcia i markery.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Anuluj'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Usuń'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        try {
          await ref.read(tripServiceProvider).deleteTrip(trip.id);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Usunięto podróż "$tripName"'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Błąd usuwania: $e'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      child: OpenContainer(
        key: Key('openContainer_${trip.id}'),
        transitionType: ContainerTransitionType.fadeThrough,
        closedBuilder: (context, action) {
          return GestureDetector(
            onTap: () async {
              await openTripLock.run(() async {
                action();
                await Future<void>.delayed(Duration.zero);
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Stack(
                children: [
                  Card(
                    clipBehavior: Clip.hardEdge,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: SizedBox(
                      height: 250,
                      width: double.infinity,
                      child: _TripCardImage(urlImage: urlImage),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        border: Border.all(
                          color: Colors.white,
                          width: 5,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(trip.status),
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStatusIcon(trip.status),
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getStatusLabel(trip.status),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  tripName,
                                  style: GoogleFonts.bebasNeue().copyWith(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formattedStartDate,
                                  style: GoogleFonts.bebasNeue().copyWith(
                                    color: const Color(0xFFB9F90B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (totalBudget > 0) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.account_balance_wallet,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${totalBudget.toStringAsFixed(2)} PLN',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        openBuilder: (context, action) {
          return MainTripDetailsScreen(
            key: const Key('tripDetailsScreen'),
            trip: trip,
          );
        },
      ),
    );
  }
}

class _TripCardImage extends StatelessWidget {
  const _TripCardImage({required this.urlImage});

  final String urlImage;

  bool get _isValidUrl =>
      urlImage.isNotEmpty && Uri.tryParse(urlImage)?.hasAbsolutePath == true;

  @override
  Widget build(BuildContext context) {
    if (!_isValidUrl) {
      return _placeholder();
    }

    return CachedNetworkImage(
      imageUrl: urlImage,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      memCacheWidth: 1200,
      memCacheHeight: 1200,
      maxWidthDiskCache: 1600,
      maxHeightDiskCache: 1600,
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 150),
      placeholder: (context, _) => _loading(),
      errorWidget: (context, _, __) => _placeholder(),
    );
  }

  Widget _loading() {
    return Container(
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
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
    );
  }
}

Color _getStatusColor(TripStatus status) {
  switch (status) {
    case TripStatus.upcoming:
      return Colors.blue;
    case TripStatus.ongoing:
      return Colors.green;
    case TripStatus.completed:
      return Colors.grey;
  }
}

IconData _getStatusIcon(TripStatus status) {
  switch (status) {
    case TripStatus.upcoming:
      return Icons.schedule;
    case TripStatus.ongoing:
      return Icons.flight_takeoff;
    case TripStatus.completed:
      return Icons.check_circle;
  }
}

String _getStatusLabel(TripStatus status) {
  switch (status) {
    case TripStatus.upcoming:
      return 'Przyszła';
    case TripStatus.ongoing:
      return 'Trwa';
    case TripStatus.completed:
      return 'Zakończona';
  }
}
