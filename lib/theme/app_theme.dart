import 'package:flutter/material.dart';

/// Islamic-themed color palette — deep teal/green (masjid domes, calligraphy se inspired)
/// aur warm gold accents (target completion ke liye).
class AppColors {
  static const primaryTeal = Color(0xFF0E6E5C);
  static const primaryTealLight = Color(0xFF14A085);
  static const gold = Color(0xFFD4AF37);
  static const lightBg = Color(0xFFF7F5EF);
  static const darkBg = Color(0xFF0F1714);
  static const darkSurface = Color(0xFF1A2420);
}

class AppTheme {
  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.lightBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryTeal,
      brightness: Brightness.light,
      primary: AppColors.primaryTeal,
      secondary: AppColors.gold,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryTeal,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryTeal,
    ),
    fontFamily: 'Roboto',
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryTealLight,
      brightness: Brightness.dark,
      primary: AppColors.primaryTealLight,
      secondary: AppColors.gold,
      surface: AppColors.darkSurface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryTealLight,
    ),
    fontFamily: 'Roboto',
  );
}
