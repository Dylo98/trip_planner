import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';

class PlacesGridEmptyState extends StatelessWidget {
  const PlacesGridEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.limeSliceDark,
            ),
            const SizedBox(height: 16),
            Text(
              'Nie znaleziono miejsc w tej kategorii',
              style: AppTextStyles.bodyText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Spróbuj wybrać inną kategorię lub oddal widok mapy',
              style: AppTextStyles.bodyTextSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
