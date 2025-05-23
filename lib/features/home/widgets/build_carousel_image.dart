import 'package:flutter/material.dart';

class BuildCarouselImage extends StatelessWidget {
  const BuildCarouselImage(
      {super.key, required this.urlImage, required this.title});

  final String urlImage;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: double.infinity,
          height: 100,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (urlImage.isNotEmpty &&
                  Uri.tryParse(urlImage)?.hasAbsolutePath == true)
                Image.network(
                  urlImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
              else
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: Text(
                    'Brak zdjęcia',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
