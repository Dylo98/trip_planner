import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/trip/controller/get_trip_provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTripsScreen extends ConsumerStatefulWidget {
  const MyTripsScreen({super.key});

  @override
  ConsumerState<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends ConsumerState<MyTripsScreen> {
  @override
  Widget build(BuildContext context) {
    int tripCount = ref.watch(getTripProvider).value?.length ?? 0;
    if (tripCount == 0) {
      return const Center(
        child: Text(
          'Nie masz jeszcze żadnych podróży',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje podróże'),
      ),
      body: ListView.builder(
        itemCount: tripCount,
        itemBuilder: (context, index) {
          String urlImage =
              ref.read(getTripProvider).value?[index].tripPhotoUrl ?? '';
          String tripName =
              ref.read(getTripProvider).value?[index].name ?? 'Brak nazwy';
          DateTime startDate =
              ref.read(getTripProvider).value?[index].startDate ??
                  DateTime.now();
          String formattedStartDate =
              DateFormat('dd-MM-yyyy').format(startDate);
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(children: [
              Card(
                clipBehavior: Clip.hardEdge,
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
                    borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }
}
