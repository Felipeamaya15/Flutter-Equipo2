import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/propuesta_valor.dart';

void main() {
  runApp(const ProductoraApp());
}

class ProductoraApp extends StatelessWidget {
  const ProductoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Productora Intercultural SpA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Llamada directa a la pantalla de la sección (PRUEBA DEMO REEMPLAZAR POR LA SECCION HOME)
      home: const PropuestaValorScreen(),
    );
  }
}