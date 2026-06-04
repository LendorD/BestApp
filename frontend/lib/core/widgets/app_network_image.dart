import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'loading_state.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.imageUrl,
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.fallbackImageUrl,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Alignment alignment;
  final String? fallbackImageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return _ImageFallback(width: width, height: height);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      placeholder: (context, _) => SkeletonBox(
        width: width,
        height: height ?? 160,
        borderRadius: BorderRadius.zero,
      ),
      errorWidget: (context, _, _) {
        if (fallbackImageUrl != null && fallbackImageUrl != imageUrl) {
          return AppNetworkImage(
            imageUrl: fallbackImageUrl!,
            fit: fit,
            width: width,
            height: height,
            alignment: alignment,
          );
        }
        return _ImageFallback(width: width, height: height);
      },
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: AppColors.surfaceAlt,
      child: const Icon(
        Icons.image_not_supported_rounded,
        color: AppColors.muted,
      ),
    );
  }
}
