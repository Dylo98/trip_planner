import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';

class FullscreenImageScreen extends StatelessWidget {
  const FullscreenImageScreen({super.key, required this.imageUrl});

  final String imageUrl;

  bool get _isValidUrl =>
      imageUrl.isNotEmpty && Uri.tryParse(imageUrl)?.hasAbsolutePath == true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(context),
        child: Center(
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: _isValidUrl
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    fadeInDuration: const Duration(milliseconds: 250),
                    fadeOutDuration: const Duration(milliseconds: 150),
                    placeholder: (context, url) => const _LoadingIndicator(),
                    errorWidget: (context, url, error) =>
                        const _ErrorPlaceholder(),
                    memCacheWidth: 2000,
                    memCacheHeight: 2000,
                    maxWidthDiskCache: 2500,
                    maxHeightDiskCache: 2500,
                  )
                : const _ErrorPlaceholder(),
          ),
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.broken_image,
        size: 80,
        color: AppColors.limeSliceDark,
      ),
    );
  }
}
