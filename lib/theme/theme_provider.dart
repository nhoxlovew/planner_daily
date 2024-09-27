import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false; // Default theme mode
  Color _textColor = Colors.black; // Default text color
  double _fontSize = 16.0; // Default font size

  bool get isDarkMode => _isDarkMode;
  Color get textColor => _textColor;
  double get fontSize => _fontSize;

  // Method to toggle between light and dark mode
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // Notify listeners about the change
  }

  // Method to set text color
  void setTextColor(Color color) {
    _textColor = color;
    notifyListeners(); // Notify listeners about the change
  }

  // Method to set font size
  void setFontSize(double size) {
    _fontSize = size;
    notifyListeners(); // Notify listeners about the change
  }

  // Method to get the current theme data
  ThemeData get themeData {
    return ThemeData(
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      // Update text theme
      textTheme: TextTheme(
        displayLarge: TextStyle(color: _textColor, fontSize: _fontSize),
        displayMedium: TextStyle(color: _textColor, fontSize: _fontSize),
        displaySmall: TextStyle(color: _textColor, fontSize: _fontSize),
        bodyLarge: TextStyle(color: _textColor, fontSize: _fontSize),
        bodyMedium: TextStyle(color: _textColor, fontSize: _fontSize),
        bodySmall: TextStyle(color: _textColor, fontSize: _fontSize),
      ),
      // You can customize other aspects of the theme as needed
      appBarTheme: AppBarTheme(
        backgroundColor: _isDarkMode ? Colors.black : Colors.white,
        titleTextStyle: TextStyle(color: _textColor, fontSize: _fontSize),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: _isDarkMode ? Colors.grey[700] : Colors.blue,
      ),
      // Add more customizations if needed
    );
  }
}
