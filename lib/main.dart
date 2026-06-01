import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/routes/app_routes.dart';
import 'features/dashboard/presentacion/viewmodels/report_viewmodel.dart';
import 'features/dashboard/presentacion/providers/solicitudes_provider.dart';
import 'features/auth/data/datasources/firebase_auth_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReportViewModel()),
        ChangeNotifierProvider(create: (_) => SolicitudesProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            repository: AuthRepositoryImpl(
              datasource: FirebaseAuthDatasource(
                firebaseAuth: firebase_auth.FirebaseAuth.instance,
              ),
            ),
          ),
        ),
      ],
      child: const ProductoraApp(),
    ),
  );
}

class ProductoraApp extends StatelessWidget {
  const ProductoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Productora Intercultural SpA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4A4B22),
        scaffoldBackgroundColor: const Color(0xFFFAF9F6),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.root, 
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}