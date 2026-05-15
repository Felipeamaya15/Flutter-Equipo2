import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color cacao = Color(0xFF3D2B1F);
  static const Color maiz = Color(0xFFF2C14E);
  static const Color arcilla = Color(0xFFB65A38);
  static const Color hoja = Color(0xFF3F6B3B);
  static const Color mar = Color(0xFF006D77);
  static const Color aji = Color(0xFFC83E2B);
  static const Color fondo = Color(0xFFF7F3EA);
  static const Color superficie = Color(0xFFFFFCF6);
  static const Color linea = Color(0xFFE5D8C5);
  static const Color texto = Color(0xFF241A14);
  static const Color textoSuave = Color(0xFF6C5A4B);
  static const Color exito = Color(0xFF2F7D4A);
}

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.mar,
        brightness: Brightness.light,
      ),
    );

    final textTheme = base.textTheme.copyWith(
      displayLarge: const TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        height: 1.12,
        color: AppColors.texto,
      ),
      headlineMedium: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.18,
        color: AppColors.texto,
      ),
      titleLarge: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: AppColors.texto,
      ),
      titleMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: AppColors.texto,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: AppColors.texto,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: AppColors.textoSuave,
      ),
      labelLarge: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.fondo,
      colorScheme: const ColorScheme.light(
        primary: AppColors.mar,
        onPrimary: Colors.white,
        secondary: AppColors.arcilla,
        onSecondary: Colors.white,
        tertiary: AppColors.maiz,
        onTertiary: AppColors.cacao,
        error: AppColors.aji,
        surface: AppColors.superficie,
        onSurface: AppColors.texto,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.fondo,
        foregroundColor: AppColors.texto,
      ),
      cardTheme: CardThemeData(
        color: AppColors.superficie,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.linea),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.mar, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.mar,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.mar,
          minimumSize: const Size(48, 46),
          side: const BorderSide(color: AppColors.mar),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.fondo,
        selectedColor: AppColors.maiz.withValues(alpha: 0.35),
        side: const BorderSide(color: AppColors.linea),
        labelStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
