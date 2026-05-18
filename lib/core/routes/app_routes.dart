import 'package:flutter/material.dart';
import 'package:flutter_equipo2/features/solicitudes/presentation/pages/login_page.dart';
import 'package:flutter_equipo2/features/solicitudes/presentation/pages/solicitud_form_page.dart';
import 'package:flutter_equipo2/features/solicitudes/presentation/pages/confirmation_page.dart';
import 'package:flutter_equipo2/features/dashboard/presentacion/pages/worker_dashboard_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String solicitudForm = '/solicitud-form';
  static const String confirmation = '/confirmation';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const WorkerDashboardPage());
      case solicitudForm:
        return MaterialPageRoute(builder: (_) => const SolicitudFormPage());
      case confirmation:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ConfirmationPage(
            folio: args?['folio'] ?? '00000',
            email: args?['email'] ?? '',
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