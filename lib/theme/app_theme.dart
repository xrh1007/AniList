import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// 全局主题配置（樱粉系二次元风格，亮色/深色两套）
class AppTheme {
  AppTheme._();

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorSchemeSeed: AppColors.lightPrimary,
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColors.lightCardBackground,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.lightAccent,
      foregroundColor: Colors.white,
      shape: CircleBorder(),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightCardBackground,
      selectedItemColor: AppColors.lightAccent,
      unselectedItemColor: AppColors.lightTextSecondary,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedColor: AppColors.lightPrimary,
      labelStyle: const TextStyle(color: AppColors.lightTextPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorSchemeSeed: AppColors.darkPrimary,
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColors.darkCardBackground,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.darkAccent,
      foregroundColor: Colors.white,
      shape: CircleBorder(),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkCardBackground,
      selectedItemColor: AppColors.darkAccent,
      unselectedItemColor: AppColors.darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedColor: AppColors.darkPrimary,
      labelStyle: const TextStyle(color: AppColors.darkTextPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}
