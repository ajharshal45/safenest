import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Global Accents
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color successGreenDark = Color(0xFF39FF14);
  static const Color successGreenLight = Color(0xFF34C759);
  static const Color errorRed = Color(0xFFFF3B30);
  static const Color warningAmber = Color(0xFFFF9500);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF051425);
  static const Color darkSurface = Color(0x0DFFFFFF); // 5% White
  static const Color darkBorder = Color(0x1AFFFFFF); // 10% White
  static const Color darkText = Color(0xFFF8FAFC);
  static const Color darkMuted = Color(0xFF94A3B8);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0x99FFFFFF); // 60% White
  static const Color lightBorder = Color(0x33000000); // 20% Black
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightMuted = Color(0xFF64748B);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent, // For background gradients
      primaryColor: primaryCyan,
      colorScheme: const ColorScheme.dark(
        primary: primaryCyan,
        secondary: primaryCyan,
        surface: darkBackground,
        error: errorRed,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: const TextStyle(color: darkText, letterSpacing: 0.2),
        bodyMedium: const TextStyle(color: darkText, letterSpacing: 0.2),
        titleLarge: const TextStyle(color: darkText, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        titleMedium: const TextStyle(color: darkText, fontWeight: FontWeight.w600, letterSpacing: 0.3),
        titleSmall: const TextStyle(color: darkMuted, fontWeight: FontWeight.w500),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: darkText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: darkText),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.transparent, // For background gradients
      primaryColor: primaryBlue,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: primaryBlue,
        surface: lightBackground,
        error: errorRed,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        bodyLarge: const TextStyle(color: lightText, letterSpacing: 0.2),
        bodyMedium: const TextStyle(color: lightText, letterSpacing: 0.2),
        titleLarge: const TextStyle(color: lightText, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        titleMedium: const TextStyle(color: lightText, fontWeight: FontWeight.w600, letterSpacing: 0.3),
        titleSmall: const TextStyle(color: lightMuted, fontWeight: FontWeight.w500),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: lightText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: lightText),
      ),
    );
  }
}
