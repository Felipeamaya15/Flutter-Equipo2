import '../entities/solicitud.dart';

abstract class SolicitudRepository {
  Future<String> crearSolicitud(Solicitud solicitud);
}