import 'package:aplicacion_estudiante/features/ubicacion/presentation/widgets/explicacion_ubicacion_dialog.dart';
import 'package:aplicacion_estudiante/shared/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<bool?> _abrir(WidgetTester tester, String boton) async {
  bool? resultado;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => resultado = await confirmarUsoUbicacion(context),
          child: const Text('abrir'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
  expect(find.text(AppStrings.locationWhyTitle), findsOneWidget);
  await tester.tap(find.text(boton));
  await tester.pumpAndSettle();
  return resultado;
}

void main() {
  testWidgets('explica el uso y devuelve true al continuar', (tester) async {
    expect(await _abrir(tester, AppStrings.continueLabel), isTrue);
  });

  testWidgets('devuelve false si la persona elige "Ahora no"', (tester) async {
    expect(await _abrir(tester, AppStrings.notNow), isFalse);
  });
}
