import 'dart:async';

import 'package:aplicacion_estudiante/core/error/failure.dart';
import 'package:aplicacion_estudiante/features/notificaciones/domain/entities/notificacion.dart';
import 'package:aplicacion_estudiante/features/notificaciones/domain/usecases/notificaciones_use_cases.dart';
import 'package:aplicacion_estudiante/features/notificaciones/presentation/controllers/resumen_notificaciones_controller.dart';
import 'package:aplicacion_estudiante/features/notificaciones/presentation/states/bandeja_state.dart';
import 'package:aplicacion_estudiante/features/notificaciones/presentation/viewmodels/bandeja_view_model.dart';
import 'package:aplicacion_estudiante/features/notificaciones/presentation/views/detalle_notificacion_page.dart';
import 'package:aplicacion_estudiante/features/notificaciones/presentation/widgets/campana_notificaciones.dart';
import 'package:aplicacion_estudiante/shared/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// Temporizador que solo "suena" cuando el test lo pide.
final class _Manual implements Timer {
  _Manual(this.alSonar);

  final void Function(Timer) alSonar;
  bool cancelado = false;

  void sonar() => alSonar(this);

  @override
  void cancel() => cancelado = true;

  @override
  bool get isActive => !cancelado;

  @override
  int get tick => 0;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ResumenNotificacionesController', () {
    late RepositorioFalso repo;
    late List<_Manual> timers;
    late List<(String, bool)> avisos;
    late ResumenNotificacionesController controller;

    setUp(() {
      repo = RepositorioFalso();
      timers = [];
      avisos = [];
      controller = ResumenNotificacionesController(
        consultarResumen: ConsultarResumenNotificacionesUseCase(repo),
        obtenerNotificaciones: ObtenerNotificacionesUseCase(repo),
        crearTemporizador: (_, alSonar) {
          final t = _Manual(alSonar);
          timers.add(t);
          return t;
        },
      )..alLlegarAvisos = (nuevos, {required alIniciar}) =>
            avisos.add((nuevos.map((n) => n.id).join(','), alIniciar));
    });

    test('al iniciar avisa de los pendientes una sola vez', () async {
      repo.todas.addAll([notificacionDePrueba(1), notificacionDePrueba(2)]);

      controller.iniciar();
      await pumpEventQueue();
      expect(controller.resumen.totalNoLeidas, 2);
      expect(avisos, [('1,2', true)]);

      // Siguiente consulta sin cambios: no repite el aviso.
      timers.last.sonar();
      await pumpEventQueue();
      expect(avisos, hasLength(1));
      controller.dispose();
    });

    test('un aviso nuevo con la app abierta se anuncia solo', () async {
      repo.todas.add(notificacionDePrueba(1));
      controller.iniciar();
      await pumpEventQueue();

      repo.todas.insert(0, notificacionDePrueba(3, alerta: true));
      timers.last.sonar();
      await pumpEventQueue();

      expect(avisos.last, ('3', false));
      expect(controller.resumen.alertasNoLeidas, 1);
      controller.dispose();
    });

    test('sin red conserva el último resumen', () async {
      repo.todas.add(notificacionDePrueba(1));
      controller.iniciar();
      await pumpEventQueue();

      repo.falla = const NetworkFailure();
      timers.last.sonar();
      await pumpEventQueue();

      expect(controller.resumen.totalNoLeidas, 1);
      controller.dispose();
    });

    test('pasa a segundo plano y vuelve: pausa y reanuda', () async {
      controller.iniciar();
      await pumpEventQueue();
      final antes = repo.consultasResumen;

      controller.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(timers.last.cancelado, isTrue);

      controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await pumpEventQueue();
      expect(repo.consultasResumen, antes + 1);
      controller.dispose();
      expect(timers.last.cancelado, isTrue);
    });
  });

  group('BandejaViewModel', () {
    test('carga, añade páginas sin repetir y actualiza un aviso', () async {
      final repo = RepositorioFalso()
        ..paginas[1] = PaginaNotificaciones(
          notificaciones: [notificacionDePrueba(3), notificacionDePrueba(2)],
          pagina: 1,
          totalPaginas: 2,
          total: 3,
        )
        ..paginas[2] = PaginaNotificaciones(
          notificaciones: [notificacionDePrueba(2), notificacionDePrueba(1)],
          pagina: 2,
          totalPaginas: 2,
          total: 3,
        );
      final vm = BandejaViewModel(
        obtenerNotificaciones: ObtenerNotificacionesUseCase(repo),
      );

      await vm.cargar();
      await vm.cargarMas();
      var datos = vm.currentState as BandejaDatos;
      expect(datos.notificaciones.map((n) => n.id), [3, 2, 1]);
      expect(datos.hayMas, isFalse);

      vm.actualizar(notificacionDePrueba(2, leida: true));
      datos = vm.currentState as BandejaDatos;
      expect(datos.notificaciones[1].leida, isTrue);
      await vm.dispose();
    });

    test('vacía, error y filtro', () async {
      final repo = RepositorioFalso();
      final vm = BandejaViewModel(
        obtenerNotificaciones: ObtenerNotificacionesUseCase(repo),
        filtroInicial: TipoNotificacion.denegacionAcceso,
      );
      await vm.cargar();
      expect(vm.currentState, isA<BandejaVacia>());
      expect(repo.pedidas.last.$2, TipoNotificacion.denegacionAcceso);

      repo.falla = const ServerFailure('Sin servicio');
      await vm.cambiarFiltro(null);
      expect((vm.currentState as BandejaError).message, 'Sin servicio');
      expect(vm.filtro, isNull);
      await vm.dispose();
    });
  });

  testWidgets('el detalle confirma la lectura y la devuelve al salir', (
    tester,
  ) async {
    final repo = RepositorioFalso()..todas.add(notificacionDePrueba(5));
    Notificacion? devuelta;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              devuelta = await Navigator.of(context).push<Notificacion>(
                MaterialPageRoute(
                  builder: (_) => DetalleNotificacionPage(
                    notificacion: notificacionDePrueba(5),
                    obtenerDetalle: ObtenerDetalleNotificacionUseCase(repo).call,
                    marcarLeida: MarcarNotificacionLeidaUseCase(repo).call,
                  ),
                ),
              );
            },
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.text('La credencial presentada ya fue utilizada.'), findsOneWidget);
    expect(
      find.text('Acércate al personal de seguridad de la puerta.'),
      findsOneWidget,
    );
    expect(repo.marcadas, [5]);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(devuelta?.leida, isTrue);
  });

  testWidgets('la campana muestra el contador y avisa del pendiente', (
    tester,
  ) async {
    final repo = RepositorioFalso()..todas.add(notificacionDePrueba(1));
    var bandejaAbierta = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              CampanaNotificaciones(
                controller: ResumenNotificacionesController(
                  consultarResumen: ConsultarResumenNotificacionesUseCase(repo),
                  obtenerNotificaciones: ObtenerNotificacionesUseCase(repo),
                ),
                onAbrirBandeja: () async => bandejaAbierta++,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('Ingreso denegado'), findsOneWidget);

    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(bandejaAbierta, 1);
    expect(find.byTooltip(AppStrings.notificationsTitle), findsOneWidget);

    // Desmonta para cancelar el temporizador de 25 s.
    await tester.pumpWidget(const SizedBox());
  });
}
