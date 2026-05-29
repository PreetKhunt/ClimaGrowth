import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppTheme {
  // ── Public API ─────────────────────────────────────────────────────────────

  static ThemeData light() => _buildLight();
  static ThemeData dark()  => _buildCinematic();

  // ── Cinematic Dark Theme ───────────────────────────────────────────────────

  static ThemeData _buildCinematic() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: kCineBg,
      colorScheme: const ColorScheme.dark(
        primary:          kCineGreen,
        secondary:        kCineBlue,
        tertiary:         kCinePurple,
        error:            Color(0xFFFF6B6B),
        surface:          kCineSurface,
        onPrimary:        kCineBg,
        onSecondary:      kCineBg,
        onSurface:        kCineText,
        onSurfaceVariant: kCineTextSub,
        outline:          kCineBorder,
        outlineVariant:   kCineCard,
      ),
      textTheme: _cinematicText(),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        foregroundColor: kCineText,
        titleTextStyle: GoogleFonts.syne(
          fontSize: 20, fontWeight: FontWeight.w700, color: kCineText),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: kCineCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: kCineBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kCineGreen,
          foregroundColor: kCineBg,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
          textStyle: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kCineGreen,
          side: const BorderSide(color: kCineGreen, width: 1.5),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kCineCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kCineBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kCineBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kCineGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
        ),
        labelStyle: GoogleFonts.figtree(fontSize: 14, color: kCineTextSub),
        hintStyle: GoogleFonts.figtree(fontSize: 14, color: kCineTextDim),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      dividerTheme: const DividerThemeData(color: kCineBorder, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: kCineCard,
        labelStyle: GoogleFonts.outfit(fontSize: 12, color: kCineText),
        side: const BorderSide(color: kCineBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  static TextTheme _cinematicText() {
    return TextTheme(
      displayLarge: GoogleFonts.syne(
          fontSize: 56, fontWeight: FontWeight.w800,
          color: kCineText, letterSpacing: -2.0, height: 1.0),
      displayMedium: GoogleFonts.syne(
          fontSize: 40, fontWeight: FontWeight.w700,
          color: kCineText, letterSpacing: -1.5),
      displaySmall: GoogleFonts.syne(
          fontSize: 32, fontWeight: FontWeight.w700,
          color: kCineText, letterSpacing: -1.0),
      headlineLarge: GoogleFonts.syne(
          fontSize: 26, fontWeight: FontWeight.w700,
          color: kCineText, letterSpacing: -0.5),
      headlineMedium: GoogleFonts.syne(
          fontSize: 22, fontWeight: FontWeight.w600, color: kCineText),
      headlineSmall: GoogleFonts.syne(
          fontSize: 18, fontWeight: FontWeight.w600, color: kCineText),
      titleLarge: GoogleFonts.outfit(
          fontSize: 18, fontWeight: FontWeight.w600, color: kCineText),
      titleMedium: GoogleFonts.outfit(
          fontSize: 15, fontWeight: FontWeight.w500, color: kCineText),
      titleSmall: GoogleFonts.outfit(
          fontSize: 13, fontWeight: FontWeight.w500, color: kCineTextSub),
      bodyLarge: GoogleFonts.figtree(
          fontSize: 16, fontWeight: FontWeight.w400, color: kCineText, height: 1.6),
      bodyMedium: GoogleFonts.figtree(
          fontSize: 14, fontWeight: FontWeight.w400, color: kCineText, height: 1.6),
      bodySmall: GoogleFonts.figtree(
          fontSize: 12, fontWeight: FontWeight.w400, color: kCineTextSub),
      labelLarge: GoogleFonts.outfit(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: kCineText, letterSpacing: 0.5),
      labelMedium: GoogleFonts.outfit(
          fontSize: 12, fontWeight: FontWeight.w500,
          color: kCineTextSub, letterSpacing: 0.8),
      labelSmall: GoogleFonts.outfit(
          fontSize: 10, fontWeight: FontWeight.w600,
          color: kCineTextSub, letterSpacing: 1.5),
    );
  }

  // ── Legacy Light Theme (unchanged) ────────────────────────────────────────

  static ThemeData _buildLight() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: kBgPrimary,
      colorScheme: const ColorScheme.light(
        primary: kAmber,
        secondary: kIndigo,
        tertiary: kSunsetOrange,
        error: kCoral,
        surface: kBgSurface,
        onPrimary: kTextPrimary,
        onSecondary: Colors.white,
        onSurface: kTextPrimary,
      ),
      textTheme: _lightText(kTextPrimary, kTextMuted),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: kBgPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        foregroundColor: kTextPrimary,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20, fontWeight: FontWeight.w700, color: kTextPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: kBgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadius),
          side: const BorderSide(color: kBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kAmber,
          foregroundColor: kTextPrimary,
          minimumSize: const Size(double.infinity, kButtonHeight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
          textStyle: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kIndigo,
          side: const BorderSide(color: kIndigo, width: 1.5),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kBgSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSmall),
          borderSide: const BorderSide(color: kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSmall),
          borderSide: const BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSmall),
          borderSide: const BorderSide(color: kAmber, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSmall),
          borderSide: const BorderSide(color: kCoral),
        ),
        labelStyle: GoogleFonts.dmSans(fontSize: 14, color: kTextMuted),
        hintStyle: GoogleFonts.dmSans(fontSize: 14, color: kTextMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dividerTheme: const DividerThemeData(color: kBorder, thickness: 1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  static TextTheme _lightText(Color primary, Color muted) {
    return TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 42, fontWeight: FontWeight.w800,
          color: primary, letterSpacing: -1.5),
      displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 32, fontWeight: FontWeight.w700,
          color: primary, letterSpacing: -1.0),
      headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 24, fontWeight: FontWeight.w700,
          color: primary, letterSpacing: -0.5),
      headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 20, fontWeight: FontWeight.w600, color: primary),
      titleLarge: GoogleFonts.dmSans(
          fontSize: 18, fontWeight: FontWeight.w500, color: primary),
      titleMedium: GoogleFonts.dmSans(
          fontSize: 16, fontWeight: FontWeight.w500, color: primary),
      bodyLarge: GoogleFonts.dmSans(
          fontSize: 18, fontWeight: FontWeight.w400, color: primary, height: 1.6),
      bodyMedium: GoogleFonts.dmSans(
          fontSize: 16, fontWeight: FontWeight.w400, color: primary, height: 1.6),
      bodySmall: GoogleFonts.dmSans(
          fontSize: 13, fontWeight: FontWeight.w400, color: muted),
      labelLarge: GoogleFonts.dmSans(
          fontSize: 17, fontWeight: FontWeight.w600, color: primary),
      labelMedium: GoogleFonts.dmSans(
          fontSize: 13, fontWeight: FontWeight.w500, color: muted, letterSpacing: 0.4),
      labelSmall: GoogleFonts.dmSans(
          fontSize: 11, fontWeight: FontWeight.w500, color: muted, letterSpacing: 0.4),
    );
  }
}
