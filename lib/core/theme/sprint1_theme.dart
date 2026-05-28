import 'package:flutter/material.dart';

import 'sprint1_colors.dart';

/// Tipografía mínima: cuerpo 16, H2 24, H1 32 (RNF8). Botones consistentes (RNF12).
ThemeData buildSprint1Theme() {
  const baseText = TextStyle(
    color: Sprint1Colors.earthDark,
    fontSize: 16,
    height: 1.45,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Sprint1Colors.terracotta,
      primary: Sprint1Colors.terracottaDeep,
      secondary: Sprint1Colors.olive,
      tertiary: Sprint1Colors.vibrantAccent,
      surface: Sprint1Colors.cream,
      error: Sprint1Colors.errorRed,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Sprint1Colors.cream,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: Sprint1Colors.earthDark,
        height: 1.2,
      ),
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Sprint1Colors.earthDark,
        height: 1.25,
      ),
      bodyLarge: baseText,
      bodyMedium: baseText,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: Sprint1Colors.cream,
      foregroundColor: Sprint1Colors.earthDark,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Sprint1Colors.errorRed, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Sprint1Colors.errorRed, width: 2),
      ),
      errorStyle: const TextStyle(
        color: Sprint1Colors.errorRed,
        fontWeight: FontWeight.w500,
      ),
      labelStyle: const TextStyle(color: Sprint1Colors.earthDark),
    ),
    expansionTileTheme: const ExpansionTileThemeData(
      shape: RoundedRectangleBorder(),
      collapsedShape: RoundedRectangleBorder(),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}
