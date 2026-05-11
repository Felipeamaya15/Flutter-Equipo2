import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_equipo2/main.dart';

void main() {
  testWidgets('muestra avances principales de UX/UI sprint 1', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Sabores Interculturales'), findsOneWidget);
    expect(find.text('Sprint 1 UX/UI en avance'), findsOneWidget);
    expect(find.text('Catalogo visual de servicios'), findsOneWidget);
    expect(find.text('Formulario de cotizacion'), findsOneWidget);
    expect(find.text('Precio estimado'), findsOneWidget);
  });

  testWidgets('valida campos obligatorios del formulario', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final submit = find.text('Enviar solicitud');
    final mainScroll = find.ancestor(of: submit, matching: find.byType(Scrollable));
    await tester.scrollUntilVisible(submit, 200, scrollable: mainScroll);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.text('Ingresa tu nombre completo'), findsOneWidget);
    expect(find.text('El correo ingresado no es valido'), findsOneWidget);
    expect(find.text('Ingresa un telefono de 9 digitos'), findsOneWidget);
    expect(find.text('Por favor selecciona la fecha de tu evento'), findsOneWidget);
  });

  testWidgets('actualiza el estimador cuando cambia invitados', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final guestsField = find.widgetWithText(TextFormField, 'Numero de invitados');
    final mainScroll = find.ancestor(of: guestsField, matching: find.byType(Scrollable));
    await tester.scrollUntilVisible(guestsField, 200, scrollable: mainScroll);
    await tester.pumpAndSettle();
    await tester.enterText(guestsField, '80');
    await tester.pumpAndSettle();

    expect(find.text('80 invitados - Evento Corporativo'), findsOneWidget);
    expect(find.text(r'$1160000'), findsOneWidget);
  });
}
