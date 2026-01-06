import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryLight = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF3B82F6);
  static const Color backgroundLight = Color(0xFFCBD5E1);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFF0F172A);
  static const Color textDark = Color(0xFFF8FAFC);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color info = Color(0xFF3B82F6,);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color chartPurple = Color(0xFF8B5CF6);
  static const Color error = Color(0xFFEF4444);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryLight,

      scaffoldBackgroundColor: backgroundLight,

      cardColor: cardLight,
      dividerColor: textSecondaryLight.withValues(alpha: 0.2),

      colorScheme: const ColorScheme.light(
        primary: primaryLight,
        secondary: textSecondaryLight,
        surface: cardLight,
        onSurface: textLight,
        error: Color(0xFFEF4444),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textLight, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: textLight, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: textLight, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: textLight, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(
          color: textLight,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(color: textLight, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textLight, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: textLight, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: textLight, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textLight),
        bodyMedium: TextStyle(color: textLight),
        bodySmall: TextStyle(color: textSecondaryLight),
        labelLarge: TextStyle(color: textLight, fontWeight: FontWeight.w600),
      ),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: cardLight,
        foregroundColor: textLight,
        surfaceTintColor: Colors.transparent,
      ),

      iconTheme: const IconThemeData(color: textLight),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: textSecondaryLight.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: textSecondaryLight.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondaryLight),
        hintStyle: TextStyle(color: textSecondaryLight.withValues(alpha: 0.7)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryDark,
      scaffoldBackgroundColor: backgroundDark,
      cardColor: cardDark,
      dividerColor: textSecondaryDark.withValues(alpha: 0.2),

      colorScheme: const ColorScheme.dark(
        primary: primaryDark,
        secondary: textSecondaryDark,
        surface: cardDark,
        onSurface: textDark,
        error: Color(0xFFEF4444),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: textDark, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: textDark, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textDark),
        bodyMedium: TextStyle(color: textDark),
        bodySmall: TextStyle(color: textSecondaryDark),
        labelLarge: TextStyle(color: textDark, fontWeight: FontWeight.w600),
      ),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: cardDark,
        foregroundColor: textDark,
        surfaceTintColor: Colors.transparent,
      ),

      iconTheme: const IconThemeData(color: textDark),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: textSecondaryDark.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: textSecondaryDark.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryDark, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondaryDark),
        hintStyle: TextStyle(color: textSecondaryDark.withValues(alpha: 0.7)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
