import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_equipo2/features/solicitudes/presentation/pages/login_page.dart';
import 'package:flutter_equipo2/features/solicitudes/presentation/pages/solicitud_form_page.dart';
import 'package:flutter_equipo2/features/solicitudes/presentation/pages/confirmation_page.dart';
import 'package:flutter_equipo2/features/dashboard/presentacion/pages/worker_dashboard_page.dart';
import 'package:flutter_equipo2/features/dashboard/presentacion/pages/report_page.dart';

class AppRoutes {
  static const String root = '/'; 
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String report = '/report';
  static const String solicitudForm = '/solicitud-form';
  static const String confirmation = '/confirmation';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case root:
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const WorkerDashboardPage());
      case report:
        return MaterialPageRoute(builder: (_) => const ReportPage());
      case solicitudForm:
        return MaterialPageRoute(builder: (_) => const SolicitudFormPage());
        
      case confirmation:
        final dynamic rawArgs = settings.arguments;
        Map<String, dynamic>? args;

        if (rawArgs is Map<String, dynamic>) {
          args = rawArgs;
        }

        return MaterialPageRoute(
          builder: (_) => ConfirmationPage(
            folio: args?['folio']?.toString() ?? '00000',
            email: args?['email']?.toString() ?? 'No disponible',
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.idTokenChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          return const WorkerDashboardPage();
        }

        return const LoginPage();
      },
    );
  }
}