import 'package:flutter/material.dart';

// EXTERNAL PACKAGES //
import 'package:carousel_slider/carousel_slider.dart';

// WIDGETS //
import 'package:trip_planner/features/home/widgets/build_carousel_image.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';

class HomeCarousel extends StatelessWidget {
  const HomeCarousel({super.key, required this.userTrips});

  final List<Trip> userTrips;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: CarouselSlider.builder(
        options: CarouselOptions(
          height: 200,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 5),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: true,
        ),
        itemCount: userTrips.length,
        itemBuilder: (context, index, realIndex) {
          final trip = userTrips[index];
          return BuildCarouselImage(
              urlImage: trip.tripPhotoUrl ?? 'Brak zdjęcia', title: trip.name);
        },
      ),
    );
  }
}
