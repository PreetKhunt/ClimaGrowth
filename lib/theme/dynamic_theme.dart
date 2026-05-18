import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

// ─── Data class (immutable) ───────────────────────────────────────────────────
class DynamicThemeData {
  // Colors
  final Color primaryColor;
  final Color secondaryColor;
  final Color bgLightColor;
  final Color bgDarkColor;
  final Color surfaceColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final Color borderColor;
  final Color weatherAccent;
  final Color soilAccent;
  final Color chatAccent;
  final Color marketAccent;

  // Typography
  final String displayFont;
  final String bodyFont;
  final double h1Size;
  final double h2Size;
  final double h3Size;
  final double bodySize;
  final double captionSize;
  final int headingWeightVal; // 400–900
  final double letterSpacingVal;
  final double lineHeightVal;

  // Spacing
  final String paddingScale; // compact | normal | comfortable | spacious
  final String borderRadiusScale; // sharp | soft | rounded | pill
  final String cardElevationLevel; // flat | subtle | raised | floating

  // Components
  final String buttonStyle; // solid | outlined | ghost | gradient | glass
  final String buttonShape; // rounded | pill | sharp
  final String buttonSize; // small | medium | large
  final String cardStyle; // flat | bordered | elevated | glass | gradient
  final String inputStyle; // outlined | filled | underline | floating

  // Effects
  final String animationSpeed; // instant | fast | normal | slow
  final String pageTransitionStyle; // fade | slide_h | slide_v | scale
  final String bgStyle; // solid | gradient | mesh
  final double glassSigmaVal;

  // Layout
  final String navStyle; // standard | floating | glass | minimalist
  final String homeLayout; // grid_2 | grid_3 | list | dashboard
  final String quickActionStyle; // square | rectangle | banner | pill

  const DynamicThemeData({
    this.primaryColor = kAmber,
    this.secondaryColor = kIndigo,
    this.bgLightColor = kBgPrimary,
    this.bgDarkColor = kBgPrimaryDark,
    this.surfaceColor = kBgSurface,
    this.textPrimaryColor = kTextPrimary,
    this.textSecondaryColor = kTextMuted,
    this.borderColor = kBorder,
    this.weatherAccent = const Color(0xFF4A90C2),
    this.soilAccent = const Color(0xFF6B8E5A),
    this.chatAccent = const Color(0xFF8E5572),
    this.marketAccent = const Color(0xFFD4A017),
    this.displayFont = 'Plus Jakarta Sans',
    this.bodyFont = 'DM Sans',
    this.h1Size = 32,
    this.h2Size = 26,
    this.h3Size = 20,
    this.bodySize = 15,
    this.captionSize = 12,
    this.headingWeightVal = 700,
    this.letterSpacingVal = 0,
    this.lineHeightVal = 1.5,
    this.paddingScale = 'normal',
    this.borderRadiusScale = 'rounded',
    this.cardElevationLevel = 'subtle',
    this.buttonStyle = 'solid',
    this.buttonShape = 'rounded',
    this.buttonSize = 'medium',
    this.cardStyle = 'bordered',
    this.inputStyle = 'outlined',
    this.animationSpeed = 'normal',
    this.pageTransitionStyle = 'fade',
    this.bgStyle = 'solid',
    this.glassSigmaVal = 16,
    this.navStyle = 'standard',
    this.homeLayout = 'grid_2',
    this.quickActionStyle = 'rectangle',
  });

  // ── Derived values ──────────────────────────────────────────────────────────
  double get padding {
    switch (paddingScale) {
      case 'compact': return 8;
      case 'comfortable': return 20;
      case 'spacious': return 28;
      default: return 16;
    }
  }

  double get radius {
    switch (borderRadiusScale) {
      case 'sharp': return 0;
      case 'soft': return 8;
      case 'pill': return 100;
      default: return 16;
    }
  }

  double get cardElevationValue {
    switch (cardElevationLevel) {
      case 'flat': return 0;
      case 'raised': return 4;
      case 'floating': return 8;
      default: return 1;
    }
  }

  double get buttonHeight {
    switch (buttonSize) {
      case 'small': return 32;
      case 'large': return 52;
      default: return 44;
    }
  }

  FontWeight get headingWeight => _fontWeightFromInt(headingWeightVal);

  static FontWeight _fontWeightFromInt(int w) {
    switch (w) {
      case 400: return FontWeight.w400;
      case 500: return FontWeight.w500;
      case 600: return FontWeight.w600;
      case 800: return FontWeight.w800;
      case 900: return FontWeight.w900;
      default: return FontWeight.w700;
    }
  }

  double get buttonBorderRadius {
    if (buttonShape == 'pill') return 100;
    if (buttonShape == 'sharp') return 4;
    return radius;
  }

  // ── copyWith ────────────────────────────────────────────────────────────────
  DynamicThemeData copyWith({
    Color? primaryColor, Color? secondaryColor,
    Color? bgLightColor, Color? bgDarkColor, Color? surfaceColor,
    Color? textPrimaryColor, Color? textSecondaryColor, Color? borderColor,
    Color? weatherAccent, Color? soilAccent, Color? chatAccent, Color? marketAccent,
    String? displayFont, String? bodyFont,
    double? h1Size, double? h2Size, double? h3Size, double? bodySize, double? captionSize,
    int? headingWeightVal, double? letterSpacingVal, double? lineHeightVal,
    String? paddingScale, String? borderRadiusScale, String? cardElevationLevel,
    String? buttonStyle, String? buttonShape, String? buttonSize,
    String? cardStyle, String? inputStyle,
    String? animationSpeed, String? pageTransitionStyle, String? bgStyle,
    double? glassSigmaVal, String? navStyle, String? homeLayout, String? quickActionStyle,
  }) => DynamicThemeData(
    primaryColor: primaryColor ?? this.primaryColor,
    secondaryColor: secondaryColor ?? this.secondaryColor,
    bgLightColor: bgLightColor ?? this.bgLightColor,
    bgDarkColor: bgDarkColor ?? this.bgDarkColor,
    surfaceColor: surfaceColor ?? this.surfaceColor,
    textPrimaryColor: textPrimaryColor ?? this.textPrimaryColor,
    textSecondaryColor: textSecondaryColor ?? this.textSecondaryColor,
    borderColor: borderColor ?? this.borderColor,
    weatherAccent: weatherAccent ?? this.weatherAccent,
    soilAccent: soilAccent ?? this.soilAccent,
    chatAccent: chatAccent ?? this.chatAccent,
    marketAccent: marketAccent ?? this.marketAccent,
    displayFont: displayFont ?? this.displayFont,
    bodyFont: bodyFont ?? this.bodyFont,
    h1Size: h1Size ?? this.h1Size, h2Size: h2Size ?? this.h2Size,
    h3Size: h3Size ?? this.h3Size, bodySize: bodySize ?? this.bodySize,
    captionSize: captionSize ?? this.captionSize,
    headingWeightVal: headingWeightVal ?? this.headingWeightVal,
    letterSpacingVal: letterSpacingVal ?? this.letterSpacingVal,
    lineHeightVal: lineHeightVal ?? this.lineHeightVal,
    paddingScale: paddingScale ?? this.paddingScale,
    borderRadiusScale: borderRadiusScale ?? this.borderRadiusScale,
    cardElevationLevel: cardElevationLevel ?? this.cardElevationLevel,
    buttonStyle: buttonStyle ?? this.buttonStyle,
    buttonShape: buttonShape ?? this.buttonShape,
    buttonSize: buttonSize ?? this.buttonSize,
    cardStyle: cardStyle ?? this.cardStyle,
    inputStyle: inputStyle ?? this.inputStyle,
    animationSpeed: animationSpeed ?? this.animationSpeed,
    pageTransitionStyle: pageTransitionStyle ?? this.pageTransitionStyle,
    bgStyle: bgStyle ?? this.bgStyle,
    glassSigmaVal: glassSigmaVal ?? this.glassSigmaVal,
    navStyle: navStyle ?? this.navStyle,
    homeLayout: homeLayout ?? this.homeLayout,
    quickActionStyle: quickActionStyle ?? this.quickActionStyle,
  );

  // ── JSON ────────────────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
    'primaryColor': primaryColor.toARGB32(), 'secondaryColor': secondaryColor.toARGB32(),
    'bgLightColor': bgLightColor.toARGB32(), 'bgDarkColor': bgDarkColor.toARGB32(),
    'surfaceColor': surfaceColor.toARGB32(), 'textPrimaryColor': textPrimaryColor.toARGB32(),
    'textSecondaryColor': textSecondaryColor.toARGB32(), 'borderColor': borderColor.toARGB32(),
    'weatherAccent': weatherAccent.toARGB32(), 'soilAccent': soilAccent.toARGB32(),
    'chatAccent': chatAccent.toARGB32(), 'marketAccent': marketAccent.toARGB32(),
    'displayFont': displayFont, 'bodyFont': bodyFont,
    'h1Size': h1Size, 'h2Size': h2Size, 'h3Size': h3Size,
    'bodySize': bodySize, 'captionSize': captionSize,
    'headingWeightVal': headingWeightVal, 'letterSpacingVal': letterSpacingVal,
    'lineHeightVal': lineHeightVal, 'paddingScale': paddingScale,
    'borderRadiusScale': borderRadiusScale, 'cardElevationLevel': cardElevationLevel,
    'buttonStyle': buttonStyle, 'buttonShape': buttonShape, 'buttonSize': buttonSize,
    'cardStyle': cardStyle, 'inputStyle': inputStyle,
    'animationSpeed': animationSpeed, 'pageTransitionStyle': pageTransitionStyle,
    'bgStyle': bgStyle, 'glassSigmaVal': glassSigmaVal,
    'navStyle': navStyle, 'homeLayout': homeLayout, 'quickActionStyle': quickActionStyle,
  };

  factory DynamicThemeData.fromJson(Map<String, dynamic> j) => DynamicThemeData(
    primaryColor: Color(j['primaryColor'] as int),
    secondaryColor: Color(j['secondaryColor'] as int),
    bgLightColor: Color(j['bgLightColor'] as int),
    bgDarkColor: Color(j['bgDarkColor'] as int),
    surfaceColor: Color(j['surfaceColor'] as int),
    textPrimaryColor: Color(j['textPrimaryColor'] as int),
    textSecondaryColor: Color(j['textSecondaryColor'] as int),
    borderColor: Color(j['borderColor'] as int),
    weatherAccent: Color(j['weatherAccent'] as int),
    soilAccent: Color(j['soilAccent'] as int),
    chatAccent: Color(j['chatAccent'] as int),
    marketAccent: Color(j['marketAccent'] as int),
    displayFont: j['displayFont'] as String,
    bodyFont: j['bodyFont'] as String,
    h1Size: (j['h1Size'] as num).toDouble(),
    h2Size: (j['h2Size'] as num).toDouble(),
    h3Size: (j['h3Size'] as num).toDouble(),
    bodySize: (j['bodySize'] as num).toDouble(),
    captionSize: (j['captionSize'] as num).toDouble(),
    headingWeightVal: j['headingWeightVal'] as int,
    letterSpacingVal: (j['letterSpacingVal'] as num).toDouble(),
    lineHeightVal: (j['lineHeightVal'] as num).toDouble(),
    paddingScale: j['paddingScale'] as String,
    borderRadiusScale: j['borderRadiusScale'] as String,
    cardElevationLevel: j['cardElevationLevel'] as String,
    buttonStyle: j['buttonStyle'] as String,
    buttonShape: j['buttonShape'] as String,
    buttonSize: j['buttonSize'] as String,
    cardStyle: j['cardStyle'] as String,
    inputStyle: j['inputStyle'] as String,
    animationSpeed: j['animationSpeed'] as String,
    pageTransitionStyle: j['pageTransitionStyle'] as String,
    bgStyle: j['bgStyle'] as String,
    glassSigmaVal: (j['glassSigmaVal'] as num).toDouble(),
    navStyle: j['navStyle'] as String,
    homeLayout: j['homeLayout'] as String,
    quickActionStyle: j['quickActionStyle'] as String,
  );

  // ── ThemeData generation ────────────────────────────────────────────────────
  ThemeData toThemeData(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? bgDarkColor : bgLightColor;
    final surface = isDark ? const Color(0xFF1C2029) : surfaceColor;
    final onSurface = isDark ? const Color(0xFFE8E6E0) : textPrimaryColor;
    final textMuted = isDark ? const Color(0xFF9E9E9E) : textSecondaryColor;
    final border = isDark ? const Color(0x14FFFFFF) : borderColor;

    TextStyle dFont(double size, FontWeight fw, {Color? c, double? ls, double? h}) =>
        _displayFontStyle(displayFont, size, fw, c ?? onSurface, ls, h);
    TextStyle bFont(double size, FontWeight fw, {Color? c, double? ls, double? h}) =>
        _bodyFontStyle(bodyFont, size, fw, c ?? onSurface, ls, h);

    final br = BorderRadius.circular(radius * 0.7);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primaryColor, secondary: secondaryColor,
              error: kCoral, surface: surface,
              onPrimary: Colors.white, onSecondary: Colors.white, onSurface: onSurface)
          : ColorScheme.light(
              primary: primaryColor, secondary: secondaryColor,
              error: kCoral, surface: surface,
              onPrimary: Colors.white, onSecondary: Colors.white, onSurface: onSurface),
      textTheme: TextTheme(
        displayLarge: dFont(h1Size + 10, FontWeight.w800, ls: -1.5),
        displayMedium: dFont(h1Size, FontWeight.w800, ls: -1.0),
        headlineLarge: dFont(h2Size, headingWeight, ls: -0.5),
        headlineMedium: dFont(h3Size, headingWeight),
        titleLarge: bFont(bodySize + 3, FontWeight.w500),
        titleMedium: bFont(bodySize + 1, FontWeight.w500),
        bodyLarge: bFont(bodySize + 3, FontWeight.w400, h: lineHeightVal),
        bodyMedium: bFont(bodySize + 1, FontWeight.w400, h: lineHeightVal),
        bodySmall: bFont(captionSize + 1, FontWeight.w400, c: textMuted),
        labelLarge: bFont(bodySize + 2, FontWeight.w600),
        labelMedium: bFont(captionSize + 1, FontWeight.w500, c: textMuted, ls: 0.4),
        labelSmall: bFont(captionSize, FontWeight.w500, c: textMuted, ls: 0.4),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0, scrolledUnderElevation: 0,
        backgroundColor: bg, foregroundColor: onSurface,
        titleTextStyle: dFont(20, FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        elevation: cardElevationValue, color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, buttonHeight),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonBorderRadius)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.5),
          minimumSize: Size(double.infinity, buttonHeight),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonBorderRadius)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: surface,
        border: OutlineInputBorder(borderRadius: br, borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: br, borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: br, borderSide: BorderSide(color: primaryColor, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: br, borderSide: const BorderSide(color: kCoral)),
        labelStyle: bFont(14, FontWeight.w400, c: textMuted),
        hintStyle: bFont(14, FontWeight.w400, c: textMuted),
        contentPadding: EdgeInsets.symmetric(horizontal: padding, vertical: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface, selectedItemColor: primaryColor,
        unselectedItemColor: textMuted, elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

// ─── Font helpers ─────────────────────────────────────────────────────────────
TextStyle _displayFontStyle(String name, double size, FontWeight fw,
    Color color, double? ls, double? h) {
  final base = TextStyle(fontSize: size, fontWeight: fw, color: color, letterSpacing: ls, height: h);
  switch (name) {
    case 'Manrope': return GoogleFonts.manrope(textStyle: base);
    case 'Sora': return GoogleFonts.sora(textStyle: base);
    case 'Outfit': return GoogleFonts.outfit(textStyle: base);
    case 'Inter': return GoogleFonts.inter(textStyle: base);
    case 'DM Sans': return GoogleFonts.dmSans(textStyle: base);
    default: return GoogleFonts.plusJakartaSans(textStyle: base);
  }
}

TextStyle _bodyFontStyle(String name, double size, FontWeight fw,
    Color color, double? ls, double? h) {
  final base = TextStyle(fontSize: size, fontWeight: fw, color: color, letterSpacing: ls, height: h);
  switch (name) {
    case 'Inter': return GoogleFonts.inter(textStyle: base);
    case 'Manrope': return GoogleFonts.manrope(textStyle: base);
    case 'Nunito Sans': return GoogleFonts.nunitoSans(textStyle: base);
    case 'Plus Jakarta Sans': return GoogleFonts.plusJakartaSans(textStyle: base);
    default: return GoogleFonts.dmSans(textStyle: base);
  }
}

// ─── Presets ──────────────────────────────────────────────────────────────────
class DynamicThemePreset {
  final String name;
  final DynamicThemeData data;
  const DynamicThemePreset(this.name, this.data);
}

class DynamicThemePresets {
  static const List<DynamicThemePreset> all = [
    DynamicThemePreset('ClimaGrowth', DynamicThemeData()),
    DynamicThemePreset('Cinematic Dark', DynamicThemeData(
      primaryColor: Color(0xFFE8B833), secondaryColor: Color(0xFF1A1A2E),
      bgLightColor: Color(0xFF0A0A0A), bgDarkColor: Color(0xFF050505),
      surfaceColor: Color(0xFF1A1A1A), textPrimaryColor: Color(0xFFF5F0E8),
      borderRadiusScale: 'soft', cardElevationLevel: 'raised',
      buttonShape: 'sharp', animationSpeed: 'slow',
    )),
    DynamicThemePreset('Premium Glass', DynamicThemeData(
      primaryColor: Color(0xFF7B61FF), secondaryColor: Color(0xFF3D2B99),
      bgLightColor: Color(0xFF0D1117), bgDarkColor: Color(0xFF080C10),
      surfaceColor: Color(0xFF161B22), textPrimaryColor: Color(0xFFE8E6E0),
      borderRadiusScale: 'rounded', cardElevationLevel: 'subtle',
      buttonStyle: 'glass', cardStyle: 'glass', glassSigmaVal: 24,
    )),
    DynamicThemePreset('Minimal Light', DynamicThemeData(
      primaryColor: Color(0xFF1A1A1A), secondaryColor: Color(0xFF757575),
      bgLightColor: Color(0xFFFFFFFF), bgDarkColor: Color(0xFF1A1A1A),
      surfaceColor: Color(0xFFF8F8F8), borderColor: Color(0x1A1A1A1A),
      borderRadiusScale: 'soft', cardElevationLevel: 'flat',
      buttonShape: 'sharp', animationSpeed: 'fast', bodyFont: 'Inter',
    )),
    DynamicThemePreset('Bold Sunrise', DynamicThemeData(
      primaryColor: Color(0xFFFF5722), secondaryColor: Color(0xFFFF9800),
      bgLightColor: Color(0xFFFFF8F5), bgDarkColor: Color(0xFF1A0A00),
      surfaceColor: Color(0xFFFFFFFF), textPrimaryColor: Color(0xFF1A0A00),
      borderRadiusScale: 'pill', cardElevationLevel: 'raised',
      buttonShape: 'pill', displayFont: 'Outfit',
    )),
    DynamicThemePreset('Calm Forest', DynamicThemeData(
      primaryColor: Color(0xFF2D6A4F), secondaryColor: Color(0xFF52B788),
      bgLightColor: Color(0xFFF0F7F4), bgDarkColor: Color(0xFF0D1F17),
      surfaceColor: Color(0xFFFFFFFF), textPrimaryColor: Color(0xFF1B3A2D),
      weatherAccent: Color(0xFF52B788), soilAccent: Color(0xFF2D6A4F),
      borderRadiusScale: 'rounded', displayFont: 'Manrope',
    )),
    DynamicThemePreset('Royal Indigo', DynamicThemeData(
      primaryColor: Color(0xFF5C6BC0), secondaryColor: Color(0xFF3949AB),
      bgLightColor: Color(0xFFF3F4FF), bgDarkColor: Color(0xFF0D0F1F),
      surfaceColor: Color(0xFFFFFFFF), textPrimaryColor: Color(0xFF1A1C3A),
      borderRadiusScale: 'rounded', displayFont: 'Sora', bodyFont: 'Inter',
    )),
    DynamicThemePreset('Soft Pastels', DynamicThemeData(
      primaryColor: Color(0xFFE08BC0), secondaryColor: Color(0xFF9DB8E0),
      bgLightColor: Color(0xFFFFF5FB), bgDarkColor: Color(0xFF1F1220),
      surfaceColor: Color(0xFFFFFFFF), textPrimaryColor: Color(0xFF2D1B2A),
      borderRadiusScale: 'pill', cardElevationLevel: 'subtle',
      buttonShape: 'pill', displayFont: 'Outfit',
    )),
    DynamicThemePreset('Tech Noir', DynamicThemeData(
      primaryColor: Color(0xFF00E5FF), secondaryColor: Color(0xFF1DE9B6),
      bgLightColor: Color(0xFF0A0E1A), bgDarkColor: Color(0xFF050710),
      surfaceColor: Color(0xFF0F1428), textPrimaryColor: Color(0xFFE0F7FA),
      borderRadiusScale: 'sharp', cardElevationLevel: 'flat',
      buttonShape: 'sharp', displayFont: 'Sora', bodyFont: 'Inter',
      animationSpeed: 'fast',
    )),
  ];
}

// ─── Provider ─────────────────────────────────────────────────────────────────
class DynamicThemeProvider extends ChangeNotifier {
  DynamicThemeData _data = const DynamicThemeData();
  static const _prefKey = 'dynamic_theme_v1';

  DynamicThemeData get data => _data;

  DynamicThemeProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw != null) {
        _data = DynamicThemeData.fromJson(
            jsonDecode(raw) as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (_) {}
  }

  // Apply + persist
  Future<void> save(DynamicThemeData d) async {
    _data = d;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, jsonEncode(d.toJson()));
    } catch (_) {}
  }

  // Apply globally without persisting (live preview in designer)
  void applyLive(DynamicThemeData d) {
    _data = d;
    notifyListeners();
  }

  Future<void> reset() async {
    await save(const DynamicThemeData());
  }
}
