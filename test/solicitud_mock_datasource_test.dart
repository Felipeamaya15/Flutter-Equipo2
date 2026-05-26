import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_equipo2/features/solicitudes/data/datasources/solicitud_mock_datasource.dart';
import 'package:flutter_equipo2/features/solicitudes/data/models/solicitud_model.dart';

void main() {
  group('SolicitudMockDatasource', () {
    late SolicitudMockDatasource mockDatasource;

    setUp(() {
      mockDatasource = SolicitudMockDatasource();
    });

    SolicitudModel crearSolicitudDePrueba() {
      return SolicitudModel(
        id: 'SOL-001',
        email: 'cliente@correo.com',
        phone: '987654321',
        fechaEvento: DateTime.now().add(const Duration(days: 10)),
        estado: 'pendiente',
        fechaCreacion: DateTime.now(),
      );
    }

    test('debe crear una solicitud simulada y retornar su id', () async {
      final solicitud = crearSolicitudDePrueba();

      final resultado = await mockDatasource.crearSolicitud(solicitud);

      expect(resultado, 'SOL-001');
    });

    test('debe guardar una solicitud en la lista simulada', () async {
      final solicitud = crearSolicitudDePrueba();

      await mockDatasource.crearSolicitud(solicitud);
      final solicitudes = await mockDatasource.obtenerSolicitudes();

      expect(solicitudes.length, 1);
      expect(solicitudes.first.id, 'SOL-001');
      expect(solicitudes.first.email, 'cliente@correo.com');
    });

    test('debe obtener una solicitud simulada por id', () async {
      final solicitud = crearSolicitudDePrueba();

      await mockDatasource.crearSolicitud(solicitud);
      final resultado = await mockDatasource.obtenerSolicitudPorId('SOL-001');

      expect(resultado, isNotNull);
      expect(resultado!.id, 'SOL-001');
    });

    test('debe retornar null si no existe la solicitud', () async {
      final resultado = await mockDatasource.obtenerSolicitudPorId('SOL-999');

      expect(resultado, isNull);
    });

    test('debe eliminar una solicitud simulada', () async {
      final solicitud = crearSolicitudDePrueba();

      await mockDatasource.crearSolicitud(solicitud);
      final eliminado = await mockDatasource.eliminarSolicitud('SOL-001');
      final solicitudes = await mockDatasource.obtenerSolicitudes();

      expect(eliminado, true);
      expect(solicitudes, isEmpty);
    });
  });
}