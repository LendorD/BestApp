import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static TextTheme textTheme() {
    final base = GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme);
    return base.apply(bodyColor: AppColors.text, displayColor: AppColors.text);
  }

  static const label = TextStyle(
    color: AppColors.muted,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );

  static const badge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w900,
    letterSpacing: 0,
  );

  static const bodyMuted = TextStyle(color: AppColors.muted, height: 1.48);
}
