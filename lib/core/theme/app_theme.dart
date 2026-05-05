import 'package:flutter/material.dart';

class AppFontSizes {
  static const double scale = 1.5;
}

class AppColors {
  // ── Semantic colors (theme-independent) ──────────────────────────────────
  static const Color primary     = Color(0xFFF5A300);
  static const Color primaryDark = Color(0xFFC68000);
  static const Color teal        = Color(0xFF00C9A7);
  static const Color green       = Color(0xFF00C853);
  static const Color red         = Color(0xFFE53935);

  // ── Instance fields (theme-dependent) ────────────────────────────────────
  final Color background;
  final Color surface;
  final Color inputBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color iconBg;
  final Color navBg;

  const AppColors._({
    required this.background,
    required this.surface,
    required this.inputBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.iconBg,
    required this.navBg,
  });

  static const _dark = AppColors._(
    background:    Color(0xFF13171F),
    surface:       Color(0xFF1E2436),
    inputBg:       Color(0xFF161A27),
    textPrimary:   Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9CAABB),
    border:        Color(0xFF2C3654),
    iconBg:        Color(0xFF252E42),
    navBg:         Color(0xFF13171F),
  );

  static const _light = AppColors._(
    background:    Color(0xFFEDEEF2),
    surface:       Color(0xFFFFFFFF),
    inputBg:       Color(0xFFF5F6F9),
    textPrimary:   Color(0xFF0F1723),
    textSecondary: Color(0xFF4A5568),
    border:        Color(0xFFD1D5E0),
    iconBg:        Color(0xFFE8EAF2),
    navBg:         Color(0xFFFFFFFF),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _dark : _light;
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF13171F),
    primaryColor: AppColors.primary,
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.teal,
      surface: Color(0xFF1E2436),
      onSurface: Color(0xFFFFFFFF),
      onSurfaceVariant: Color(0xFF9CAABB),
      outline: Color(0xFF2C3654),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF13171F),
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E2436),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerColor: const Color(0xFF2C3654),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF161A27),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Color(0xFF9CAABB)),
    ),
  );

  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFEDEEF2),
    primaryColor: AppColors.primary,
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.teal,
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF0F1723),
      onSurfaceVariant: Color(0xFF4A5568),
      outline: Color(0xFFD1D5E0),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFFFFF),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: Color(0xFF0F1723),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Color(0xFF0F1723)),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFFFFFFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerColor: const Color(0xFFD1D5E0),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F6F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Color(0xFF4A5568)),
    ),
  );
}
