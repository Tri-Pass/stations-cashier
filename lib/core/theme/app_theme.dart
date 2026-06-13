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

  // Matches pro.stations.wetaxi.ma exactly
  static const _dark = AppColors._(
    background:    Color(0xFF1A1E2A),
    surface:       Color(0xFF222834),
    inputBg:       Color(0xFF1A2030),
    textPrimary:   Color(0xFFFFFFFF),
    textSecondary: Color(0xFF8896A8),
    border:        Color(0xFF2E3650),
    iconBg:        Color(0xFF252D3D),
    navBg:         Color(0xFF1A1E2A),
  );

  static const _light = AppColors._(
    background:    Color(0xFFFFFFFF),
    surface:       Color(0xFFF2F4F7),
    inputBg:       Color(0xFFE9EDF3),
    textPrimary:   Color(0xFF0D0F14),
    textSecondary: Color(0xFF52596B),
    border:        Color(0xFFC8CDD8),
    iconBg:        Color(0xFFFFF3D6),
    navBg:         Color(0xFFFFFFFF),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _dark : _light;
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1E2A),
        primaryColor: AppColors.primary,
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.teal,
          surface: Color(0xFF222834),
          onSurface: Color(0xFFFFFFFF),
          onSurfaceVariant: Color(0xFF8896A8),
          outline: Color(0xFF2E3650),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1E2A),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF222834),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        dividerColor: const Color(0xFF2E3650),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A2030),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Color(0xFF8896A8)),
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        primaryColor: AppColors.primary,
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.teal,
          surface: Color(0xFFF2F4F7),
          onSurface: Color(0xFF0D0F14),
          onSurfaceVariant: Color(0xFF52596B),
          outline: Color(0xFFC8CDD8),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Color(0xFF0D0F14),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Color(0xFF0D0F14)),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFF2F4F7),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        dividerColor: const Color(0xFFC8CDD8),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFE9EDF3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Color(0xFF52596B)),
        ),
      );
}
