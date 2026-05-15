import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/pages/worker_dashboard_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
      home: const WorkerDashboardPage(),
    );
  }
}
