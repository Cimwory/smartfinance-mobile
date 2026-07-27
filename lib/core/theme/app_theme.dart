import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF4F85F6); // Blue matching the web Sign in button
  static const Color secondaryColor = Color(0xFF14B8A6); // Teal for accents
  static const Color backgroundColor = Color(0xFF040b16); // Very dark blue/black background
  static const Color cardColor = Color(0xFF0f172a); // Dark slate for containers
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94a3b8); // Slate 400

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
        surface: cardColor,
      ),
      textTheme: ThemeData.dark().textTheme.copyWith(
        displayLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        titleLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(color: textPrimary),
        bodyMedium: const TextStyle(color: textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        labelStyle: TextStyle(color: textSecondary, fontSize: 14),
        hintStyle: TextStyle(color: textSecondary, fontSize: 14),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF334155)), // Slate 700
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
