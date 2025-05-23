import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  @override
  Widget build(BuildContext context) {
    int tripCount = 11;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje podróże'),
      ),
      body: GridView.custom(
        gridDelegate: SliverWovenGridDelegate.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          pattern: [
            WovenGridTile(1),
            WovenGridTile(
              5 / 7,
              crossAxisRatio: 0.9,
              alignment: AlignmentDirectional.centerEnd,
            ),
          ],
        ),
        childrenDelegate: SliverChildBuilderDelegate(
          (context, index) {
            return Card(
              child: Column(
                children: [
                  Expanded(
                    child: Image.network(
                      'https://via.placeholder.com/150',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Podróż ${index + 1}'),
                  ),
                ],
              ),
            );
          },
          childCount: tripCount,
        ),
      ),
    );
  }
}
