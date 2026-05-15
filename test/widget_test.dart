import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_equipo2/main.dart';

void main() {
  testWidgets('muestra el dashboard principal del trabajador', (tester) async {
    await tester.pumpWidget(const ProductoraApp());
    await tester.pumpAndSettle();

    expect(find.text('Panel trabajador'), findsWidgets);
    expect(find.text('Solicitudes activas'), findsOneWidget);
    expect(find.text('Eventos de la semana'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Prioridades operativas'), findsOneWidget);
    expect(find.text('Agenda de hoy'), findsOneWidget);
  });

  testWidgets('permite abrir el formulario desde nueva solicitud', (
    tester,
  ) async {
    await tester.pumpWidget(const ProductoraApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(FilledButton, 'Nueva solicitud').first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Solicitud de'), findsOneWidget);
    expect(find.text('Enviar solicitud'), findsOneWidget);
  });

  testWidgets('aplica controles e iconografia del dashboard', (tester) async {
    await tester.pumpWidget(const ProductoraApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.assignment_outlined), findsWidgets);
    expect(find.byIcon(Icons.event_available_outlined), findsOneWidget);
    expect(find.text('Reporte'), findsOneWidget);
  });
}
