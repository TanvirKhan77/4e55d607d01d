import 'package:flutter/material.dart';

// ThemeProvider: Manages app theme state (light/dark mode)
class ThemeProvider extends ChangeNotifier {
  // Private property: Stores current theme mode
  bool _isDarkMode = false;

  // Public getter: Provides read-only access to theme state
  bool get isDarkMode => _isDarkMode;

  // Method: Toggle between light and dark mode
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Method: Set theme mode explicitly
  void setDarkMode(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }
}
