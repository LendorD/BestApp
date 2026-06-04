import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppShadows {
  static List<BoxShadow> panel = [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.42),
      blurRadius: 18,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> glass({double alpha = 0.1}) => [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.48),
      blurRadius: 20,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: AppColors.neon.withValues(alpha: alpha),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> lifted(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 10),
    ),
  ];
}
