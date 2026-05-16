import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameMentorColors {
  static const background = Color(0xFF070A12);
  static const surface = Color(0xFF101522);
  static const surfaceAlt = Color(0xFF151C2E);
  static const border = Color(0xFF273148);
  static const text = Color(0xFFF5F7FB);
  static const muted = Color(0xFF9AA7BD);
  static const purple = Color(0xFF8A5CFF);
  static const blue = Color(0xFF2F8CFF);
  static const green = Color(0xFF24D18B);
  static const red = Color(0xFFFF5C7C);
  static const amber = Color(0xFFFFC857);
}

class GameMentorTheme {
  static ThemeData dark() {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: GameMentorColors.background,
      colorScheme: const ColorScheme.dark(
        primary: GameMentorColors.purple,
        secondary: GameMentorColors.blue,
        tertiary: GameMentorColors.green,
        surface: GameMentorColors.surface,
        error: GameMentorColors.red,
      ),
      textTheme: textTheme.apply(
        bodyColor: GameMentorColors.text,
        displayColor: GameMentorColors.text,
      ),
      cardTheme: const CardThemeData(
        color: GameMentorColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(color: GameMentorColors.border),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GameMentorColors.surfaceAlt.withValues(alpha: 0.88),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: GameMentorColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: GameMentorColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: GameMentorColors.blue,
            width: 1.5,
          ),
        ),
        labelStyle: const TextStyle(color: GameMentorColors.muted),
        hintStyle: const TextStyle(color: GameMentorColors.muted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GameMentorColors.purple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GameMentorColors.text,
          side: const BorderSide(color: GameMentorColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: GameMentorColors.surfaceAlt,
        selectedColor: GameMentorColors.purple.withValues(alpha: 0.22),
        side: const BorderSide(color: GameMentorColors.border),
        labelStyle: const TextStyle(color: GameMentorColors.text),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
