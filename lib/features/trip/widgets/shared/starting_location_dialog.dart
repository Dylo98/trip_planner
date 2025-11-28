import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/core/widgets/dialog/dialog_header.dart';

class StartingLocationDialog extends StatelessWidget {
  const StartingLocationDialog({
    super.key,
    required this.onUseCurrentLocation,
    required this.onSearchLocation,
  });

  final VoidCallback onUseCurrentLocation;
  final VoidCallback onSearchLocation;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DialogHeader(
            title: 'Lokalizacja startowa',
            icon: Icons.location_pin,
            onClose: () => Navigator.of(context).pop(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wybierz punkt startowy swojej podróży',
                  style: AppTextStyles.bodyTextSecondary,
                ),
                const SizedBox(height: 24),
                _OptionCard(
                  icon: Icons.my_location,
                  iconColor: AppColors.primary,
                  title: 'Użyj obecnej lokalizacji',
                  subtitle: 'Automatycznie ustaw punkt startowy',
                  onTap: onUseCurrentLocation,
                ),
                const SizedBox(height: 12),
                _OptionCard(
                  icon: Icons.search,
                  iconColor: Colors.blue,
                  title: 'Wyszukaj miejsce',
                  subtitle: 'Wybierz punkt na mapie',
                  onTap: onSearchLocation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyText,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyTextSecondary,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.limeSliceDark,
            ),
          ],
        ),
      ),
    );
  }
}
