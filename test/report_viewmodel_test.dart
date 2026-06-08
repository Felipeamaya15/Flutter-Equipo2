import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_equipo2/features/dashboard/presentacion/viewmodels/report_viewmodel.dart';

void main() {
  group('ReportViewModel - validación de rango de fechas', () {
    test('Debe bloquear reporte si fecha Desde es posterior a fecha Hasta', () {
      final viewModel = ReportViewModel();

      final resultado = viewModel.validarRangoFechas(
        DateTime(2026, 7, 1),
        DateTime(2024, 7, 1),
      );

      expect(resultado, false);
      expect(viewModel.errorMessage, isNotNull);
      expect(
        viewModel.errorMessage,
        'La fecha "Desde" no puede ser posterior a la fecha "Hasta".',
      );
    });

    test('Debe permitir reporte si fecha Desde es anterior a fecha Hasta', () {
      final viewModel = ReportViewModel();

      final resultado = viewModel.validarRangoFechas(
        DateTime(2024, 7, 1),
        DateTime(2026, 7, 1),
      );

      expect(resultado, true);
      expect(viewModel.errorMessage, isNull);
    });

    test('Debe permitir reporte si fecha Desde es igual a fecha Hasta', () {
      final viewModel = ReportViewModel();

      final resultado = viewModel.validarRangoFechas(
        DateTime(2026, 7, 1),
        DateTime(2026, 7, 1),
      );

      expect(resultado, true);
      expect(viewModel.errorMessage, isNull);
    });

    test('Debe bloquear reporte si falta una de las fechas', () {
      final viewModel = ReportViewModel();

      final resultado = viewModel.validarRangoFechas(
        DateTime(2026, 7, 1),
        null,
      );

      expect(resultado, false);
      expect(
        viewModel.errorMessage,
        'Debes seleccionar ambas fechas para generar el reporte.',
      );
    });
  });
}