import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/features/trip/widgets/form_input.dart';

class TransformLatlng extends StatefulWidget {
  const TransformLatlng({super.key});

  @override
  State<TransformLatlng> createState() => _TransformLatlngState();
}

class _TransformLatlngState extends State<TransformLatlng> {
  String placeM = '';
  String addressOnScreen = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: FormInput(
                labelText: 'Punkt podróży',
                icon: Icons.place,
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              onPressed: () {},
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          addressOnScreen,
        ),
        Text(
          placeM,
        ),
        GestureDetector(
          onTap: () async {
            List<Location> locations = await locationFromAddress(
              'Polska, Warszawa',
            );
            List<Placemark> placemark = await placemarkFromCoordinates(
              52.2297,
              21.0122,
            );
            setState(() {
              placeM =
                  '${placemark.reversed.last.country}, ${placemark.reversed.last.locality}, ${placemark.reversed.last.street}, ${placemark.reversed.last.subLocality}';
              addressOnScreen =
                  '${locations.last.longitude}, ${locations.last.latitude}';
            });
          },
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              height: 50,
              width: double.infinity,
              color: Colors.blue,
              child: const Center(
                child: Text(
                  'Transform',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
