import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF051425);
  static const Color cardSurface = Color(0xFF122032);
  static const Color cardBorder = Color(0xFF3E484F);
  static const Color primaryAccent = Color(0xFF8ED5FF);
  static const Color primaryContainer = Color(0xFF38BDF8); // Sky blue
  static const Color onSurfaceText = Color(0xFFD5E3FC);
  static const Color mutedText = Color(0xFFBDC8D1);
  
  static const Color errorBorder = Color(0xFF93000A);
  static const Color errorText = Color(0xFFFFB4AB);
  
  static const Color successBg = Color(0xFF166534);
  static const Color successText = Color(0xFF86EFAC);
  
  static const Color warningBg = Color(0xFF78350F);
  static const Color warningText = Color(0xFFFCD34D);

  static const Color bottomNavBorder = Color(0xFF334155);
  static const Color navActive = Color(0xFF38BDF8);
  static const Color navInactive = Color(0xFF475569);

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primaryContainer,
      colorScheme: const ColorScheme.dark(
        primary: primaryContainer,
        secondary: primaryAccent,
        surface: cardSurface,
        error: errorBorder,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: const TextStyle(color: onSurfaceText),
        bodyMedium: const TextStyle(color: onSurfaceText),
        titleLarge: const TextStyle(color: onSurfaceText),
        titleMedium: const TextStyle(color: onSurfaceText),
        titleSmall: const TextStyle(color: mutedText),
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: navActive,
        unselectedItemColor: navInactive,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: onSurfaceText,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
