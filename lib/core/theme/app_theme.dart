import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Minimalist Editorial Luxury Design System for Ivory Nails Atelier.
/// Warm porcelain ivory ground, muted petal blush accents, deep charcoal text,
/// whisper-thin borders, and high-fashion editorial serif typography.
class AppTheme {
  // --------------------------------------------------------------------------
  // COLOR PALETTE
  // --------------------------------------------------------------------------
  static const Color ivoryGround = Color(0xFFFBF9F7);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color linenSurface = Color(0xFFF6F2EF);

  // Muted Blush Spectrum
  static const Color blush50 = Color(0xFFFCF7F6);
  static const Color blush100 = Color(0xFFF5EBE8);
  static const Color blush200 = Color(0xFFEBD7D3);
  static const Color blush300 = Color(0xFFDCBCB6);
  static const Color blush400 = Color(0xFFC99992);
  static const Color dustyRose = Color(0xFFB57770);
  static const Color deepRose = Color(0xFF94524B);

  // Neutrals (Warm Stone & Charcoal)
  static const Color charcoalNoir = Color(0xFF1C1917);
  static const Color velvetNoir = Color(0xFF141211);
  static const Color textMuted = Color(0xFF78716C);
  static const Color textSubtle = Color(0xFFA8A29E);
  static const Color delicateBorder = Color(0xFFE8E2DD);
  static const Color borderSubtle = Color(0xFFF0EBE7);
  static const Color warmTaupe = Color(0xFF8C827A);
  static const Color satinCream = Color(0xFFFFFDFB);

  // Accents
  static const Color goldAccent = Color(0xFFB8966E);
  static const Color goldChampagne = Color(0xFFC5A880);
  static const Color emeraldSuccess = Color(0xFF2E6B49);
  static const Color amberWarning = Color(0xFFB47833);
  static const Color errorCrimson = Color(0xFFA83A3A);

  // --------------------------------------------------------------------------
  // SHADOWS (Tactile & Soft)
  // --------------------------------------------------------------------------
  static List<BoxShadow> get subtleDepth => [
        BoxShadow(
          color: const Color(0xFF1C1917).withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: const Color(0xFF1C1917).withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevatedDepth => [
        BoxShadow(
          color: const Color(0xFF1C1917).withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: const Color(0xFF1C1917).withValues(alpha: 0.12),
          blurRadius: 32,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: const Color(0xFFB57770).withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF1C1917).withValues(alpha: 0.04),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: const Color(0xFFB57770).withValues(alpha: 0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get editorialShadow => [
        BoxShadow(
          color: const Color(0xFF1C1917).withValues(alpha: 0.04),
          blurRadius: 32,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: const Color(0xFFB57770).withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get cardHoverShadow => [
        BoxShadow(
          color: const Color(0xFF1C1917).withValues(alpha: 0.08),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: const Color(0xFFB57770).withValues(alpha: 0.12),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get modalShadow => [
        BoxShadow(
          color: const Color(0xFF1C1917).withValues(alpha: 0.16),
          blurRadius: 40,
          offset: const Offset(0, 20),
        ),
      ];

  // --------------------------------------------------------------------------
  // THEME DATA
  // --------------------------------------------------------------------------
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: ivoryGround,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: dustyRose,
        onPrimary: pureWhite,
        secondary: goldAccent,
        onSecondary: pureWhite,
        surface: pureWhite,
        onSurface: charcoalNoir,
        error: errorCrimson,
        onError: pureWhite,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: ivoryGround,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: charcoalNoir),
      ),

      // Typography
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 48,
          fontWeight: FontWeight.w600,
          color: charcoalNoir,
          letterSpacing: -0.5,
          height: 1.15,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: charcoalNoir,
          letterSpacing: -0.3,
          height: 1.2,
        ),
        displaySmall: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: charcoalNoir,
          height: 1.25,
        ),
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: charcoalNoir,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: charcoalNoir,
        ),
        headlineSmall: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: charcoalNoir,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: charcoalNoir,
          letterSpacing: 0.1,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: charcoalNoir,
        ),
        titleSmall: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textMuted,
          letterSpacing: 0.5,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: charcoalNoir,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textMuted,
          height: 1.55,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: textSubtle,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pureWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: delicateBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: delicateBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dustyRose, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorCrimson, width: 1),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: textSubtle,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: textMuted,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: charcoalNoir,
          foregroundColor: pureWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: charcoalNoir,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: const BorderSide(color: delicateBorder, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: dustyRose,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: delicateBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
