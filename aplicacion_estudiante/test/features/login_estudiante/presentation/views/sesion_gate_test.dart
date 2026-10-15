import 'dart:async';

import 'package:aplicacion_estudiante/features/login_estudiante/domain/entities/usuario.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/presentation/views/sesion_gate.dart';
import 'package:aplicacion_estudiante/shared/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _usuario = Usuario(
  id: 1,
  codigoInstitucional: '2026087688',
  correoInstitucional: 'estudiante@virtual.upt.pe',
  nombres: 'Ana',
  apellidos: 'Pérez',
  roles: ['ESTUDIANTE'],
);

Widget _app(Future<Usuario?> Function() restaurar) => MaterialApp(
  home: SesionGate(
    restaurarSesion: restaurar,
    construirLogin: (_) => const Text('LOGIN'),
    construirInicio: (_) => const Text('IDENTIDAD'),
  ),
);

void main() {
  testWidgets('muestra la preparación mientras restaura', (tester) async {
    final pendiente = Completer<Usuario?>();
    await tester.pumpWidget(_app(() => pendiente.future));

    expect(find.text(AppStrings.preparingSession), findsOneWidget);

    pendiente.complete(null);
    await tester.pumpAndSettle();
  });

  testWidgets('con sesión válida entra directo a la identidad', (tester) async {
    await tester.pumpWidget(_app(() async => _usuario));
    await tester.pumpAndSettle();

    expect(find.text('IDENTIDAD'), findsOneWidget);
    expect(find.text('LOGIN'), findsNothing);
  });

  testWidgets('sin sesión muestra el login', (tester) async {
    await tester.pumpWidget(_app(() async => null));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('si restaurar falla muestra el login', (tester) async {
    await tester.pumpWidget(_app(() async => throw Exception('sin red')));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN'), findsOneWidget);
  });
}
