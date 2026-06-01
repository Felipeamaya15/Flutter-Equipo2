import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_equipo2/core/utils/validators.dart';

void main() {
  group('Validadores Regex - rechazo de strings corruptos', () {
    test('Debe rechazar correos electrónicos corruptos', () {
      final correosCorruptos = [
        '',
        'correo',
        'correo@',
        '@correo.com',
        'correo.com',
        'correo@@gmail.com',
        'correo@gmail',
        'correo gmail@gmail.com',
        'correo<script>@gmail.com',
        'cliente@.com',
        'cliente@correo.',
      ];

      for (final correo in correosCorruptos) {
        expect(
          Validators.email(correo),
          isNotNull,
          reason: 'El correo corrupto "$correo" fue aceptado incorrectamente',
        );
      }
    });

    test('Debe rechazar teléfonos corruptos', () {
      final telefonosCorruptos = [
        '',
        '123',
        '12345678',
        '1234567890',
        'abcdefghi',
        '12345abcd',
        '+56912345678',
        '9 1234 5678',
        '91234-5678',
        '<script>123</script>',
        '98765432a',
      ];

      for (final telefono in telefonosCorruptos) {
        expect(
          Validators.phone(telefono),
          isNotNull,
          reason: 'El teléfono corrupto "$telefono" fue aceptado incorrectamente',
        );
      }
    });

    test('Debe aceptar correos electrónicos válidos', () {
      final correosValidos = [
        'cliente@correo.com',
        'usuario.test@gmail.com',
        'nombre_apellido@dominio.cl',
      ];

      for (final correo in correosValidos) {
        expect(
          Validators.email(correo),
          isNull,
          reason: 'El correo válido "$correo" fue rechazado incorrectamente',
        );
      }
    });

    test('Debe aceptar teléfonos válidos de 9 dígitos', () {
      final telefonosValidos = [
        '987654321',
        '912345678',
        '123456789',
      ];

      for (final telefono in telefonosValidos) {
        expect(
          Validators.phone(telefono),
          isNull,
          reason: 'El teléfono válido "$telefono" fue rechazado incorrectamente',
        );
      }
    });
  });
}