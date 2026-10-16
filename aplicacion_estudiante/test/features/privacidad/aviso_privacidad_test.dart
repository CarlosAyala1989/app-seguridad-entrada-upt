import 'package:aplicacion_estudiante/features/privacidad/data/aviso_privacidad_vigente.dart';
import 'package:aplicacion_estudiante/features/privacidad/domain/entities/aviso_privacidad.dart';
import 'package:aplicacion_estudiante/features/privacidad/presentation/views/aviso_privacidad_page.dart';
import 'package:aplicacion_estudiante/features/ubicacion/presentation/widgets/explicacion_ubicacion_dialog.dart';
import 'package:aplicacion_estudiante/shared/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AvisoPrivacidad', () {
    test('el aviso vigente explica el uso de la ubicación', () {
      expect(avisoPrivacidadVigente.explicaUbicacion, isTrue);
      expect(avisoPrivacidadVigente.version, isNotEmpty);
    });

    test('detecta un aviso que no menciona la ubicación', () {
      final aviso = AvisoPrivacidad(
        version: '0.1',
        vigenteDesde: DateTime(2026, 1, 5),
        secciones: const [
          SeccionAviso(titulo: 'Datos', parrafos: ['Nombre y código.']),
        ],
      );
      expect(aviso.explicaUbicacion, isFalse);
    });

    test('formatea la fecha de vigencia como dd/mm/aaaa', () {
      final aviso = AvisoPrivacidad(
        version: '1.0',
        vigenteDesde: DateTime(2026, 3, 7),
        secciones: const [],
      );
      expect(aviso.vigenteDesdeTexto, '07/03/2026');
    });
  });

  testWidgets('la pantalla muestra la versión y cada apartado', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: AvisoPrivacidadPage(aviso: avisoPrivacidadVigente)),
    );

    expect(find.text(AppStrings.privacyTitle), findsOneWidget);
    expect(
      find.textContaining('${AppStrings.privacyVersion} 1.0'),
      findsOneWidget,
    );
    for (final seccion in avisoPrivacidadVigente.secciones) {
      await tester.scrollUntilVisible(find.text(seccion.titulo), 200);
      expect(find.text(seccion.titulo), findsOneWidget);
    }
  });

  testWidgets('"Más información" abre el aviso sin cerrar la explicación', (
    tester,
  ) async {
    var abierto = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => confirmarUsoUbicacion(
              context,
              onVerAvisoPrivacidad: () => abierto++,
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.moreInfo));
    await tester.pumpAndSettle();

    expect(abierto, 1);
    expect(find.text(AppStrings.locationWhyTitle), findsOneWidget);
  });

  testWidgets('sin enlace no aparece "Más información"', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => confirmarUsoUbicacion(context),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.moreInfo), findsNothing);
  });
}
