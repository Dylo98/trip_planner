import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/features/home/constants/layout_constants.dart';
import 'package:trip_planner/features/auth/providers/user_provider.dart';

class BuildCoverImage extends ConsumerWidget {
  const BuildCoverImage({super.key});

  static const String _fallbackAsset = 'assets/images/image_home.jpg';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meAsync = ref.watch(meProvider);

    return meAsync.when(
      data: (me) {
        final coverImageUrl = me?.coverImage;
        final hasCoverImage =
            coverImageUrl != null && coverImageUrl.trim().isNotEmpty;

        if (!hasCoverImage) return _fallbackImage();

        return Container(
          color: AppColors.black,
          child: Image.network(
            coverImageUrl.trim(),
            height: LayoutConstants.coverHeight,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallbackImage(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;

              final expected = loadingProgress.expectedTotalBytes;
              final loaded = loadingProgress.cumulativeBytesLoaded;
              final value = expected != null ? loaded / expected : null;

              return _loadingPlaceholder(progress: value);
            },
          ),
        );
      },
      loading: () => _loadingPlaceholder(),
      error: (_, __) => _fallbackImage(),
    );
  }

  Widget _fallbackImage() {
    return Container(
      color: AppColors.black,
      child: Image.asset(
        _fallbackAsset,
        height: LayoutConstants.coverHeight,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _loadingPlaceholder({double? progress}) {
    return Container(
      height: LayoutConstants.coverHeight,
      width: double.infinity,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: CircularProgressIndicator(value: progress),
    );
  }
}
