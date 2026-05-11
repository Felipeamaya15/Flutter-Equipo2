import 'package:flutter/material.dart';

import 'core/theme/sprint1_theme.dart';
import 'features/landing/presentation/landing_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sabores Interculturales',
      debugShowCheckedModeBanner: false,
      theme: buildSprint1Theme(),
      home: const LandingPage(),
    );
  }
}
