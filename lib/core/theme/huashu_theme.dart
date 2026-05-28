import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HuashuTheme {
  // Token Warna Mineral Tradisional
  static const Color xuanPaperBg = Color(0xFFF7F5F0);
  static const Color charcoalBlack = Color(0xFF1E1E1E);
  static const Color mineralJadeGreen = Color(0xFF2D5A43);
  static const Color stainedCinnabarRed = Color(0xFFB83A2C);
  static const Color lightInkLine = Color(0xFFE2DFD5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: xuanPaperBg,
      colorScheme: const ColorScheme.light(
        primary: mineralJadeGreen,
        secondary: charcoalBlack,
        error: stainedCinnabarRed,
        surface: xuanPaperBg,
      ),
      
      // Pembatalan Card Radius Tebal (Anti-Slop)
      cardTheme: const CardThemeData(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: lightInkLine, width: 0.5),
          borderRadius: BorderRadius.zero,
        ),
      ),
      
      // Tipografi Ritme Puitis (Serif Klasik + Sans-Serif clean)
      textTheme: TextTheme(
        displayLarge: GoogleFonts.notoSerifSc(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: charcoalBlack,
        ),
        headlineMedium: GoogleFonts.notoSerifSc(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: charcoalBlack,
        ),
        titleMedium: GoogleFonts.notoSerifSc(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: charcoalBlack,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          height: 1.6,
          color: charcoalBlack,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          height: 1.5,
          color: charcoalBlack.withOpacity(0.8),
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w500,
          color: charcoalBlack.withOpacity(0.6),
        ),
      ),

      // Input Field Bergaya Underscore Tradisional
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: charcoalBlack, width: 0.5),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: lightInkLine, width: 0.5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: mineralJadeGreen, width: 1.0),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: stainedCinnabarRed, width: 0.5),
        ),
        labelStyle: TextStyle(color: charcoalBlack),
        floatingLabelStyle: TextStyle(color: mineralJadeGreen),
      ),

      // Tombol Aksi Persegi Tajam (0px Radius)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: charcoalBlack,
          foregroundColor: xuanPaperBg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Persegi tajam
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
