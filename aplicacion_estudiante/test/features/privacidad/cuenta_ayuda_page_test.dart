import 'package:aplicacion_estudiante/core/config/legal_config.dart';
import 'package:aplicacion_estudiante/features/privacidad/presentation/views/cuenta_ayuda_page.dart';
import 'package:aplicacion_estudiante/shared/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('las páginas solo aceptan HTTPS sin credenciales en la URL', () {
    for (final value in [
      '',
      'mailto:soporte@upt.pe',
      'http://upt.pe/datos',
      'https://usuario:clave@upt.pe',
    ]) {
      expect(LegalConfig.uriPublica(value), isNull);
    }
    expect(LegalConfig.uriPublica('https://upt.pe/privacidad')?.host, 'upt.pe');
  });

  testWidgets('los enlaces vacíos avisan y no abren ninguna página', (
    tester,
  ) async {
    var llamadas = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: CuentaAyudaPage(
          config: const LegalConfig(
            privacidad: '',
            soporte: '',
            eliminarCuenta: '',
          ),
          onVerAvisoPrivacidad: () {},
          abrirPagina: (_) async {
            llamadas++;
            return true;
          },
        ),
      ),
    );
    await tester.tap(find.text(AppStrings.publicPrivacyPolicy));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.pageUnavailable), findsOneWidget);
    expect(llamadas, 0);
  });

  testWidgets(
    'eliminar permite cancelar y abre la ruta pública del portal configurado',
    (tester) async {
      final abiertas = <Uri>[];
      await tester.pumpWidget(
        MaterialApp(
          home: CuentaAyudaPage(
            onVerAvisoPrivacidad: () {},
            abrirPagina: (uri) async {
              abiertas.add(uri);
              return true;
            },
          ),
        ),
      );
      await tester.ensureVisible(find.text(AppStrings.deleteAccount));
      await tester.tap(find.text(AppStrings.deleteAccount));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.cancel));
      await tester.pumpAndSettle();
      expect(abiertas, isEmpty);

      await tester.tap(find.text(AppStrings.deleteAccount));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueLabel));
      await tester.pumpAndSettle();
      expect(
        abiertas.single.toString(),
        'https://ingreso-upt.fottuto.men/eliminar-cuenta',
      );
      expect(abiertas.single.query, isEmpty);
      // Abrir la página no se presenta como una cuenta ya eliminada.
      expect(find.byType(CuentaAyudaPage), findsOneWidget);
    },
  );

  testWidgets('un fallo del navegador se muestra y permite reintentar', (
    tester,
  ) async {
    var intentos = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: CuentaAyudaPage(
          config: const LegalConfig(soporte: 'https://upt.pe/soporte'),
          onVerAvisoPrivacidad: () {},
          abrirPagina: (_) async {
            intentos++;
            throw StateError('navegador no disponible');
          },
        ),
      ),
    );
    await tester.tap(find.text(AppStrings.supportTitle));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.pageOpenError), findsOneWidget);
    await tester.tap(find.text(AppStrings.supportTitle));
    await tester.pumpAndSettle();
    expect(intentos, 2);
  });

  testWidgets('el aviso local y los permisos se abren sin iniciar sesión', (
    tester,
  ) async {
    var avisos = 0;
    var ajustes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: CuentaAyudaPage(
          onVerAvisoPrivacidad: () => avisos++,
          abrirAjustes: () async {
            ajustes++;
            return false;
          },
        ),
      ),
    );
    await tester.tap(find.text(AppStrings.privacyTitle));
    expect(avisos, 1);
    await tester.tap(find.text(AppStrings.permissionSettings));
    await tester.pumpAndSettle();
    expect(ajustes, 1);
    expect(find.text(AppStrings.settingsOpenError), findsOneWidget);
  });

  testWidgets('cuenta y ayuda admite texto grande en un iPhone pequeño', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: CuentaAyudaPage(onVerAvisoPrivacidad: () {}),
      ),
    );
    await tester.scrollUntilVisible(find.text(AppStrings.deleteAccount), 200);
    expect(tester.takeException(), isNull);
  });
}
