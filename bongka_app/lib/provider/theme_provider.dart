import 'package:flutter/material.dart';

/// Placeholder theme provider so the app compiles and dark-mode
/// support can be dropped in later (shared_preferences is already
/// in pubspec.yaml for persisting the choice).
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
