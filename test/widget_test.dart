import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('carga pantalla basica de prueba', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Panel trabajador'),
          ),
        ),
      ),
    );

    expect(find.text('Panel trabajador'), findsOneWidget);
  });

  testWidgets('muestra boton de nueva solicitud', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Nueva solicitud'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Nueva solicitud'), findsOneWidget);
  });

  testWidgets('muestra icono de cierre de sesion', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Icon(Icons.logout_rounded),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
  });
}