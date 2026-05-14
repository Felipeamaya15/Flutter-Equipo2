import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'core/theme/app_theme.dart';
import 'screens/solicitud_form_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); 

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
      home: SolicitudForm(), 
    );
  }
}