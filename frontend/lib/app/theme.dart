import 'package:flutter/material.dart';

import 'design_system/app_colors.dart';
import 'design_system/app_theme.dart';

export 'design_system/app_colors.dart';
export 'design_system/app_shadows.dart';
export 'design_system/app_spacing.dart';
export 'design_system/app_theme.dart';
export 'design_system/app_typography.dart';

abstract final class GameMentorColors {
  static const background = AppColors.background;
  static const backgroundElevated = AppColors.backgroundElevated;
  static const surface = AppColors.surface;
  static const surfaceAlt = AppColors.surfaceAlt;
  static const surfaceGlass = AppColors.surfaceGlass;
  static const border = AppColors.border;
  static const borderStrong = AppColors.borderStrong;
  static const text = AppColors.text;
  static const textSoft = AppColors.textSoft;
  static const muted = AppColors.muted;
  static const mutedDeep = AppColors.mutedDeep;
  static const purple = AppColors.purple;
  static const blue = AppColors.blue;
  static const green = AppColors.green;
  static const red = AppColors.red;
  static const amber = AppColors.amber;
  static const white = AppColors.white;
  static const black = AppColors.black;
}

abstract final class GameMentorTheme {
  static ThemeData dark() => AppTheme.dark();
}
