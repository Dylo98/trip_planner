import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/home/constants/layout_constants.dart';
import 'package:trip_planner/features/auth/controller/user_provider.dart';

class BuildCoverImage extends ConsumerWidget {
  const BuildCoverImage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meAsync = ref.watch(meProvider);

    return meAsync.when(
      data: (me) {
        final coverImageUrl = me?.coverImage;
        final hasCoverImage = coverImageUrl?.isNotEmpty == true;

        return Container(
          color: Colors.black,
          child: hasCoverImage
              ? Image.network(
                  coverImageUrl!,
                  height: LayoutConstants.coverHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/image_home.jpg',
                      height: LayoutConstants.coverHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: LayoutConstants.coverHeight,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                )
              : Image.asset(
                  'assets/images/image_home.jpg',
                  height: LayoutConstants.coverHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
        );
      },
      loading: () => Container(
        color: Colors.grey.shade300,
        height: LayoutConstants.coverHeight,
        width: double.infinity,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => Container(
        color: Colors.black,
        child: Image.asset(
          'assets/images/image_home.jpg',
          height: LayoutConstants.coverHeight,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
