import 'package:flutter/material.dart';

class AppTheme {
  //Tonos tierra
  static const Color primaryGreen = Color(0xFF4A6B22); 
  static const Color earthBrown = Color(0xFF8B5A2B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: earthBrown,
      ),
      // Tamaños mínimos de tipografía (H1 > 32px, Body > 16px) 
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32.0, 
          fontWeight: FontWeight.bold, 
          color: primaryGreen
        ),
        bodyLarge: TextStyle(
          fontSize: 16.0, 
          color: Colors.black87
        ),
      ),
    );
  }
}