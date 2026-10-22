import 'package:aplicacion_estudiante/features/biometria/presentation/views/bloqueo_biometrico_gate.dart';
import 'package:aplicacion_estudiante/features/biometria/presentation/widgets/ajustes_biometria_tile.dart';
import 'package:aplicacion_estudiante/shared/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({
  required bool bloquear,
  required List<bool> respuestas,
  void Function()? alCerrarSesion,
}) => MaterialApp(
  home: BloqueoBiometricoGate(
    debeBloquear: () async => bloquear,
    desbloquear: () async => respuestas.removeAt(0),
    onCerrarSesion: () async => alCerrarSesion?.call(),
    child: const Scaffold(body: Text('IDENTIDAD')),
  ),
);

void main() {
  testWidgets('sin bloqueo activado muestra la app', (tester) async {
    await tester.pumpWidget(_app(bloquear: false, respuestas: []));
    await tester.pumpAndSettle();

    expect(find.text('IDENTIDAD'), findsOneWidget);
    expect(find.text(AppStrings.lockedTitle), findsNothing);
  });

  testWidgets('con bloqueo pide la huella y al confirmarla se abre', (
    tester,
  ) async {
    await tester.pumpWidget(_app(bloquear: true, respuestas: [true]));
    await tester.pumpAndSettle();

    expect(find.text('IDENTIDAD'), findsOneWidget);
    expect(find.text(AppStrings.lockedTitle), findsNothing);
  });

  testWidgets('si falla la huella la app sigue tapada hasta reintentar', (
    tester,
  ) async {
    await tester.pumpWidget(_app(bloquear: true, respuestas: [false, true]));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.lockedTitle), findsOneWidget);
    expect(find.text('IDENTIDAD'), findsNothing);

    await tester.tap(find.text(AppStrings.unlock));
    await tester.pumpAndSettle();

    expect(find.text('IDENTIDAD'), findsOneWidget);
  });

  testWidgets('desde el bloqueo se puede cerrar sesión', (tester) async {
    var cerrada = false;
    await tester.pumpWidget(
      _app(
        bloquear: true,
        respuestas: [false],
        alCerrarSesion: () => cerrada = true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.logout));
    await tester.pumpAndSettle();

    expect(cerrada, isTrue);
  });

  group('AjustesBiometriaTile', () {
    Widget tile({required bool disponible, required List<bool> llamadas}) =>
        MaterialApp(
          home: Scaffold(
            body: AjustesBiometriaTile(
              estaDisponible: () async => disponible,
              estaActivada: () async => false,
              activar: () async {
                llamadas.add(true);
                return true;
              },
              desactivar: () async => llamadas.add(false),
            ),
          ),
        );

    testWidgets('no aparece si el teléfono no tiene biometría', (
      tester,
    ) async {
      await tester.pumpWidget(tile(disponible: false, llamadas: []));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.biometricsTitle), findsNothing);
    });

    testWidgets('activar y desactivar llaman al caso de uso', (tester) async {
      final llamadas = <bool>[];
      await tester.pumpWidget(tile(disponible: true, llamadas: llamadas));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(llamadas, [true, false]);
    });
  });
}
