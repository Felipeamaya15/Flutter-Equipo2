import 'package:flutter_test/flutter_test.dart';

bool esCorreoValido(String correo) {
  final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
  return regex.hasMatch(correo);
}

bool esTelefonoValido(String telefono) {
  final regex = RegExp(r'^\d{9}$');
  return regex.hasMatch(telefono);
}

bool esFechaFutura(DateTime fecha) {
  final hoy = DateTime.now();
  final fechaActual = DateTime(hoy.year, hoy.month, hoy.day);
  final fechaIngresada = DateTime(fecha.year, fecha.month, fecha.day);

  return fechaIngresada.isAfter(fechaActual);
}

bool camposObligatoriosCompletos({
  required String nombre,
  required String correo,
  required String telefono,
  required String tipoEvento,
  required String numeroInvitados,
  required DateTime? fechaEvento,
}) {
  return nombre.trim().isNotEmpty &&
      correo.trim().isNotEmpty &&
      telefono.trim().isNotEmpty &&
      tipoEvento.trim().isNotEmpty &&
      numeroInvitados.trim().isNotEmpty &&
      fechaEvento != null;
}

void main() {
  group('Validaciones del formulario de solicitud', () {
    test('El correo electrónico debe tener un formato válido', () {
      expect(esCorreoValido('cliente@correo.com'), true);
      expect(esCorreoValido('cliente_correo.com'), false);
      expect(esCorreoValido('cliente@correo'), false);
    });

    test('El teléfono debe contener exactamente 9 dígitos', () {
      expect(esTelefonoValido('987654321'), true);
      expect(esTelefonoValido('12345'), false);
      expect(esTelefonoValido('98765432a'), false);
    });

    test('La fecha del evento debe ser futura', () {
      final manana = DateTime.now().add(const Duration(days: 1));
      final ayer = DateTime.now().subtract(const Duration(days: 1));

      expect(esFechaFutura(manana), true);
      expect(esFechaFutura(ayer), false);
    });

    test('Los campos obligatorios deben estar completos', () {
      final resultado = camposObligatoriosCompletos(
        nombre: 'Juan Pérez',
        correo: 'juan@correo.com',
        telefono: '987654321',
        tipoEvento: 'Corporativo',
        numeroInvitados: '50',
        fechaEvento: DateTime.now().add(const Duration(days: 10)),
      );

      expect(resultado, true);
    });

    test('El formulario no debe validarse si falta un campo obligatorio', () {
      final resultado = camposObligatoriosCompletos(
        nombre: '',
        correo: 'juan@correo.com',
        telefono: '987654321',
        tipoEvento: 'Corporativo',
        numeroInvitados: '50',
        fechaEvento: DateTime.now().add(const Duration(days: 10)),
      );

      expect(resultado, false);
    });
  });
}