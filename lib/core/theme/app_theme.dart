import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color bgAmoled = Color(0xFF050508);
  static const Color bgCyber = Color(0xFF0D0E15);
  static const Color bgCard = Color(0xFF141622);
  static const Color neonCyan = Color(0xFF00F3FF);
  static const Color neonPink = Color(0xFFFF0055);
  static const Color neonYellow = Color(0xFFFFEE00);
  static const Color textMain = Color(0xFFE2E8F0);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderCyber = Color(0xFF1E293B);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgAmoled,
      primaryColor: AppColors.neonCyan,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonCyan,
        secondary: AppColors.neonPink,
        surface: AppColors.bgCard,
        onSurface: AppColors.textMain,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(color: AppColors.textMain, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.orbitron(color: AppColors.textMain, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.orbitron(color: AppColors.textMain, fontWeight: FontWeight.w600),
        headlineLarge: GoogleFonts.orbitron(color: AppColors.textMain, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.orbitron(color: AppColors.textMain, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.orbitron(color: AppColors.textMain),
        titleLarge: GoogleFonts.orbitron(color: AppColors.textMain, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.rajdhani(color: AppColors.textMain, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.rajdhani(color: AppColors.textMuted),
        bodyLarge: GoogleFonts.rajdhani(color: AppColors.textMain, fontSize: 16),
        bodyMedium: GoogleFonts.rajdhani(color: AppColors.textMain, fontSize: 14),
        bodySmall: GoogleFonts.rajdhani(color: AppColors.textMuted, fontSize: 12),
        labelLarge: GoogleFonts.orbitron(color: AppColors.bgAmoled, fontWeight: FontWeight.bold, fontSize: 14),
        labelMedium: GoogleFonts.orbitron(color: AppColors.neonCyan, fontSize: 12),
        labelSmall: GoogleFonts.rajdhani(color: AppColors.textMuted, fontSize: 11),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgCyber,
        foregroundColor: AppColors.neonCyan,
        titleTextStyle: GoogleFonts.orbitron(
          color: AppColors.neonCyan,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        iconTheme: const IconThemeData(color: AppColors.neonCyan),
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgCyber,
        selectedItemColor: AppColors.neonCyan,
        unselectedItemColor: AppColors.textMuted,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.borderCyber),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.bgCard,
        titleTextStyle: TextStyle(color: AppColors.neonCyan),
      ),
      dividerColor: AppColors.borderCyber,
      iconTheme: const IconThemeData(color: AppColors.textMuted),
    );
  }

  static List<BoxShadow> neonGlow(Color color, {double blur = 12, double spread = 0}) => [
    BoxShadow(color: color.withOpacity(0.6), blurRadius: blur, spreadRadius: spread),
    BoxShadow(color: color.withOpacity(0.3), blurRadius: blur * 2, spreadRadius: spread),
  ];

  static List<BoxShadow> get cyanGlow => neonGlow(AppColors.neonCyan);
  static List<BoxShadow> get pinkGlow => neonGlow(AppColors.neonPink);
  static List<BoxShadow> get yellowGlow => neonGlow(AppColors.neonYellow);
}
