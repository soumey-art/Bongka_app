import 'package:flutter/material.dart';
import 'app_color.dart';


class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: AppColors.backgroundColor,

    colorScheme: const ColorScheme.light(
      primary: AppColors.blueColor,
      error: AppColors.redColor,
      background: AppColors.backgroundColor,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.blueColor,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textColor,
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColors.textColor,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        color: Colors.grey,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blueColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.blueColor),
      ),
    ),
  );
}