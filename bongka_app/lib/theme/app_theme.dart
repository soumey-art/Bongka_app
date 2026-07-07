import 'package:flutter/material.dart';
import 'app_color.dart';

<<<<<<< HEAD
=======

>>>>>>> 155565cc5fe36546ef9c6118ccee665d19a5ba0f
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: AppColors.backgroundColor,

    colorScheme: const ColorScheme.light(
      primary: AppColors.blueColor,
      error: AppColors.redColor,
<<<<<<< HEAD
      surface: AppColors.backgroundColor,
=======
      background: AppColors.backgroundColor,
>>>>>>> 155565cc5fe36546ef9c6118ccee665d19a5ba0f
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
<<<<<<< HEAD
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.textColor),
      bodySmall: TextStyle(fontSize: 14, color: Colors.grey),
=======
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColors.textColor,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        color: Colors.grey,
      ),
>>>>>>> 155565cc5fe36546ef9c6118ccee665d19a5ba0f
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blueColor,
        foregroundColor: Colors.white,
<<<<<<< HEAD
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
=======
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
>>>>>>> 155565cc5fe36546ef9c6118ccee665d19a5ba0f
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
<<<<<<< HEAD
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
=======
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
>>>>>>> 155565cc5fe36546ef9c6118ccee665d19a5ba0f
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.blueColor),
      ),
    ),
  );
<<<<<<< HEAD
}
=======
}
>>>>>>> 155565cc5fe36546ef9c6118ccee665d19a5ba0f
