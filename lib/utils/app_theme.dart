import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData light() {
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
      textTheme: _textTheme(kTextPrimary, kTextMuted),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: kBgPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        foregroundColor: kTextPrimary,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: kTextPrimary,
        ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
          textStyle:
              GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kIndigo,
          side: const BorderSide(color: kIndigo, width: 1.5),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle:
              GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: kBgSurface,
        selectedItemColor: kAmber,
        unselectedItemColor: kTextMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: kBgTertiary,
        labelStyle: GoogleFonts.dmSans(fontSize: 13, color: kTextPrimary),
        side: const BorderSide(color: kBorder),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusPill)),
      ),
      dividerTheme: const DividerThemeData(color: kBorder, thickness: 1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: kBgPrimaryDark,
      colorScheme: const ColorScheme.dark(
        primary: kAmberDarkMode,
        secondary: kIndigoDarkMode,
        tertiary: kSunsetOrange,
        error: kCoral,
        surface: kBgSurfaceDark,
        onPrimary: kTextPrimaryDark,
        onSecondary: Colors.white,
        onSurface: kTextPrimaryDark,
      ),
      textTheme: _textTheme(kTextPrimaryDark, kTextMutedDark),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: kBgPrimaryDark,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        foregroundColor: kTextPrimaryDark,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: kTextPrimaryDark,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: kBgSurfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadius),
          side: const BorderSide(color: Color(0x14FFFFFF)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kAmber,
          foregroundColor: kTextPrimary,
          minimumSize: const Size(double.infinity, kButtonHeight),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
          textStyle:
              GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kAmberDarkMode,
          side: const BorderSide(color: kAmberDarkMode, width: 1.5),
          minimumSize: const Size(double.infinity, 56),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle:
              GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kBgSurfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSmall),
          borderSide: const BorderSide(color: Color(0x14FFFFFF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSmall),
          borderSide: const BorderSide(color: Color(0x14FFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSmall),
          borderSide: const BorderSide(color: kAmberDarkMode, width: 2),
        ),
        labelStyle: GoogleFonts.dmSans(fontSize: 14, color: kTextSecondaryDark),
        hintStyle: GoogleFonts.dmSans(fontSize: 14, color: kTextSecondaryDark),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dividerTheme:
          const DividerThemeData(color: Color(0x14FFFFFF), thickness: 1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  static TextTheme _textTheme(Color primary, Color muted) {
    return TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 42,
          fontWeight: FontWeight.w800,
          color: primary,
          letterSpacing: -1.5),
      displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: primary,
          letterSpacing: -1.0),
      headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: primary,
          letterSpacing: -0.5),
      headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 20, fontWeight: FontWeight.w600, color: primary),
      titleLarge: GoogleFonts.dmSans(
          fontSize: 18, fontWeight: FontWeight.w500, color: primary),
      titleMedium: GoogleFonts.dmSans(
          fontSize: 16, fontWeight: FontWeight.w500, color: primary),
      bodyLarge: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: primary,
          height: 1.6),
      bodyMedium: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: primary,
          height: 1.6),
      bodySmall: GoogleFonts.dmSans(
          fontSize: 13, fontWeight: FontWeight.w400, color: muted),
      labelLarge: GoogleFonts.dmSans(
          fontSize: 17, fontWeight: FontWeight.w600, color: primary),
      labelMedium: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: muted,
          letterSpacing: 0.4),
      labelSmall: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: muted,
          letterSpacing: 0.4),
    );
  }
}
