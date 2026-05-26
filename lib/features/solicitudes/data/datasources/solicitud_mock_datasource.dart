import '../models/solicitud_model.dart';

class SolicitudMockDatasource {
  final List<SolicitudModel> _solicitudes = [];

  Future<String> crearSolicitud(SolicitudModel solicitud) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _solicitudes.add(solicitud);

    return solicitud.id;
  }

  Future<List<SolicitudModel>> obtenerSolicitudes() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return List.unmodifiable(_solicitudes);
  }

  Future<SolicitudModel?> obtenerSolicitudPorId(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return _solicitudes.firstWhere((solicitud) => solicitud.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> eliminarSolicitud(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final cantidadInicial = _solicitudes.length;
    _solicitudes.removeWhere((solicitud) => solicitud.id == id);

    return _solicitudes.length < cantidadInicial;
  }

  void limpiarDatos() {
    _solicitudes.clear();
  }
}