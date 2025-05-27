import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trip_planner/features/trip/controller/get_trip_provider.dart';
import 'package:trip_planner/features/trip/screens/trip_details.dart';

class MyTrip extends ConsumerStatefulWidget {
  const MyTrip({super.key});

  @override
  ConsumerState<MyTrip> createState() => _MyTripState();
}

class _MyTripState extends ConsumerState<MyTrip> {
  @override
  Widget build(BuildContext context) {
    final tripData = ref.watch(getTripProvider).value ?? [];
    if (tripData.isEmpty) {
      return const Center(
        // TODO: Add a widget to display when there are no trips
        child: Text(
          'Nie masz jeszcze żadnych podróży',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      itemCount: tripData.length,
      itemBuilder: (context, index) {
        final trip = tripData[index];
        String urlImage = trip.tripPhotoUrl ?? '';
        String tripName = trip.name;
        String formattedStartDate =
            DateFormat('dd-MM-yyyy').format(trip.startDate);
        return OpenContainer(
          key: Key('openContainer_${trip.id}'),
          transitionType: ContainerTransitionType.fadeThrough,
          closedBuilder: (context, action) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(children: [
                Card(
                  clipBehavior: Clip.hardEdge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: urlImage.isNotEmpty &&
                            Uri.tryParse(urlImage)?.hasAbsolutePath == true
                        ? Image.network(
                            urlImage,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Container(
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
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  top: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      border: Border.all(
                        color: Colors.white,
                        width: 5,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
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
                            color: Color(0xFFB9F90B),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            );
          },
          openBuilder: (context, action) {
            return TripDetailsScreen(
              key: Key('tripDetailsScreen'),
              trip: trip,
            );
          },
        );
      },
    );
  }
}
