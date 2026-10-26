import 'package:aplicacion_estudiante/features/notificaciones/domain/entities/notificacion.dart';
import 'package:aplicacion_estudiante/features/notificaciones/domain/usecases/notificaciones_use_cases.dart';
import 'package:aplicacion_estudiante/features/notificaciones/presentation/controllers/resumen_notificaciones_controller.dart';
import 'package:aplicacion_estudiante/features/notificaciones/presentation/viewmodels/bandeja_view_model.dart';
import 'package:aplicacion_estudiante/features/notificaciones/presentation/views/bandeja_notificaciones_page.dart';
import 'package:aplicacion_estudiante/features/notificaciones/presentation/views/detalle_notificacion_page.dart';
import 'package:aplicacion_estudiante/features/notificaciones/presentation/widgets/alerta_seguridad_banner.dart';
import 'package:aplicacion_estudiante/features/notificaciones/presentation/widgets/notificacion_tile.dart';
import 'package:aplicacion_estudiante/shared/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

ResumenNotificacionesController _controller(RepositorioFalso repo) =>
    ResumenNotificacionesController(
      consultarResumen: ConsultarResumenNotificacionesUseCase(repo),
      obtenerNotificaciones: ObtenerNotificacionesUseCase(repo),
    );

void main() {
  testWidgets('una alerta se distingue de una denegación', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              NotificacionTile(
                notificacion: notificacionDePrueba(1, alerta: true),
                onTap: () {},
              ),
              NotificacionTile(
                notificacion: notificacionDePrueba(2),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.textContaining(AppStrings.securityAlert), findsOneWidget);
    expect(find.byIcon(Icons.gpp_maybe), findsOneWidget);
    expect(find.byIcon(Icons.block), findsOneWidget);
  });

  testWidgets('el filtro "Alertas" pide solo intentos sospechosos', (
    tester,
  ) async {
    final repo = RepositorioFalso()
      ..todas.addAll([
        notificacionDePrueba(1, alerta: true),
        notificacionDePrueba(2),
      ]);
    await tester.pumpWidget(
      MaterialApp(
        home: BandejaNotificacionesPage(
          viewModel: BandejaViewModel(
            obtenerNotificaciones: ObtenerNotificacionesUseCase(repo),
          ),
          abrirDetalle: (context, notificacion) async => null,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(NotificacionTile), findsNWidgets(2));

    await tester.tap(find.text(AppStrings.notificationsAlerts));
    await tester.pumpAndSettle();

    expect(repo.pedidas.last.$2, TipoNotificacion.intentoSospechoso);
    expect(find.byType(NotificacionTile), findsOneWidget);
  });

  testWidgets('el detalle de una alerta explica qué significa', (
    tester,
  ) async {
    final repo = RepositorioFalso()
      ..todas.add(notificacionDePrueba(9, alerta: true));
    await tester.pumpWidget(
      MaterialApp(
        home: DetalleNotificacionPage(
          notificacion: notificacionDePrueba(9, alerta: true),
          obtenerDetalle: ObtenerDetalleNotificacionUseCase(repo).call,
          marcarLeida: MarcarNotificacionLeidaUseCase(repo).call,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.securityAlertHelp), findsOneWidget);
  });

  testWidgets('la alerta destacada aparece solo con alertas sin leer', (
    tester,
  ) async {
    final repo = RepositorioFalso()
      ..todas.add(notificacionDePrueba(1, alerta: true));
    final controller = _controller(repo);
    var revisadas = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AlertaSeguridadBanner(
            controller: controller,
            onRevisar: () async => revisadas++,
          ),
        ),
      ),
    );
    await controller.actualizar();
    await tester.pump();
    expect(find.text(AppStrings.alertsBannerOne), findsOneWidget);

    await tester.tap(find.text(AppStrings.review));
    await tester.pump();
    expect(revisadas, 1);

    // Al leerla, el aviso destacado desaparece.
    await repo.marcarLeida(1);
    await controller.actualizar();
    await tester.pump();
    expect(find.text(AppStrings.alertsBannerOne), findsNothing);

    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
