import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color backgroundColor = Color(0xFF0B1626); // main dark navy bg
  static const Color surfaceColor = Color(0xFF14213A);    // cards, input fields
  static const Color surfaceBorder = Color(0xFF263E5E);   // borders on cards/inputs

  // Text
  static const Color textColor = Color(0xFFFFFFFF);       // primary text (on dark bg)
  static const Color textSecondary = Color(0xFF85B7EB);   // labels, taglines
  static const Color textMuted = Color(0xFF5F6B7A);       // placeholders, hints

  // Brand accent (blue)
  static const Color blueColor = Color(0xFF378ADD);       // primary accent / buttons
  static const Color blueDark = Color(0xFF042C53);        // text/icons on blue fills

  // Status colors (kept separate from brand so they stay meaningful)
  static const Color redColor = Color(0xFFE24B4A);        // danger / threat detected
  static const Color yellowColor = Color(0xFFEF9F27);      // warning / caution
  static const Color greenColor = Color(0xFF639922);       // safe / good score
}
