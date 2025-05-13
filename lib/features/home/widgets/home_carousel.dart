import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:trip_planner/features/home/widgets/build_carousel_image.dart';

class HomeCarousel extends StatelessWidget {
  const HomeCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> originalImages = [
      'https://picsum.photos/200/300?random=1',
      'https://picsum.photos/200/300?random=2',
      'https://picsum.photos/200/300?random=3',
      'https://picsum.photos/200/300?random=4',
      'https://picsum.photos/200/300?random=5',
    ];

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
        itemCount: originalImages.length,
        itemBuilder: (context, index, realIndex) {
          final urlImage = originalImages[index];
          return BuildCarouselImage(urlImage: urlImage);
        },
      ),
    );
  }
}
