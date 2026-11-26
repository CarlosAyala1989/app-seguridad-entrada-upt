import 'dart:async';

import 'package:aplicacion_estudiante/core/error/failure.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/domain/entities/codigo_qr.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/domain/repositories/codigo_qr_repository.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/domain/usecases/generar_codigo_qr_use_case.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/domain/usecases/revocar_codigo_qr_use_case.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/presentation/states/codigo_qr_state.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/presentation/viewmodels/codigo_qr_view_model.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/presentation/views/codigo_qr_page.dart';
import 'package:aplicacion_estudiante/features/ubicacion/domain/entities/ubicacion_dispositivo.dart';
import 'package:aplicacion_estudiante/features/ubicacion/domain/repositories/ubicacion_repository.dart';
import 'package:aplicacion_estudiante/features/ubicacion/domain/usecases/obtener_ubicacion_confiable_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

/// Temporizador que solo avanza cuando el test lo pide.
final class _TemporizadorManual implements Timer {
  _TemporizadorManual(this.alSonar);

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

final class _Ubicacion implements UbicacionRepository {
  _Ubicacion(this.ahora);

  final DateTime Function() ahora;

  Completer<UbicacionDispositivo>? pendiente;

  @override
  Future<UbicacionDispositivo> obtenerUbicacionActual() async =>
      pendiente != null
      ? pendiente!.future
      : UbicacionDispositivo(
          latitud: -18.013,
          longitud: -70.251,
          precisionMetros: 5,
          obtenidaEn: ahora(),
        );
}

final class _Repositorio implements CodigoQrRepository {
  _Repositorio(this.ahora);

  final DateTime Function() ahora;
  int generados = 0;
  Failure? fallaAlGenerar;
  Failure? fallaAlRevocar;
  Duration vigencia = const Duration(seconds: 30);
  Future<void>? esperaGeneracion;

  @override
  Future<CodigoQr> generar(UbicacionDispositivo ubicacion) async {
    final f = fallaAlGenerar;
    if (f != null) throw f;
    generados++;
    await esperaGeneracion;
    return CodigoQr(
      contenido: 'qr-$generados',
      estado: 'PENDIENTE',
      emitidoEn: ahora(),
      expiraEn: ahora().add(vigencia),
      duracionSegundos: vigencia.inSeconds,
      unSoloUso: true,
      puntoAccesoNombre: 'Puerta principal',
    );
  }

  @override
  Future<void> revocarActual() async {
    final f = fallaAlRevocar;
    if (f != null) throw f;
  }
}

void main() {
  late DateTime ahora;
  late _Repositorio repo;
  late List<_TemporizadorManual> temporizadores;
  late CodigoQrViewModel vm;
  late _Ubicacion ubicacion;

  setUp(() {
    ahora = DateTime(2026, 10, 15, 12);
    repo = _Repositorio(() => ahora);
    temporizadores = [];
    ubicacion = _Ubicacion(() => ahora);
    vm = CodigoQrViewModel(
      generarCodigoQr: GenerarCodigoQrUseCase(
        obtenerUbicacion: ObtenerUbicacionConfiableUseCase(
          ubicacion,
          ahora: () => ahora,
        ),
        repository: repo,
      ),
      revocarCodigoQr: RevocarCodigoQrUseCase(repo),
      ahora: () => ahora,
      crearTemporizador: (_, alSonar) {
        final t = _TemporizadorManual(alSonar);
        temporizadores.add(t);
        return t;
      },
    );
  });

  tearDown(() => vm.dispose());

  test('al generar muestra el código con su cuenta regresiva', () async {
    await vm.generar();

    final estado = vm.currentState as CodigoQrVisible;
    expect(estado.codigo.contenido, 'qr-1');
    expect(estado.segundosRestantes, 30);

    ahora = ahora.add(const Duration(seconds: 10));
    temporizadores.last.sonar();
    expect((vm.currentState as CodigoQrVisible).segundosRestantes, 20);
  });

  test('al vencer pide otro código automáticamente', () async {
    await vm.generar();

    ahora = ahora.add(const Duration(seconds: 31));
    temporizadores.last.sonar();
    await pumpEventQueue();

    expect(repo.generados, 2);
    expect((vm.currentState as CodigoQrVisible).codigo.contenido, 'qr-2');
    expect(temporizadores.first.cancelado, isTrue);
  });

  test('sin rotación automática vuelve al estado inicial al vencer', () async {
    await vm.generar(rotacionAutomatica: false);

    ahora = ahora.add(const Duration(seconds: 31));
    temporizadores.last.sonar();

    expect(vm.currentState, isA<CodigoQrInicial>());
    expect(repo.generados, 1);
  });

  test('un error de la API se muestra y detiene la rotación', () async {
    repo.fallaAlGenerar = const ServerFailure('Fuera de la zona permitida');

    await vm.generar();

    expect(vm.currentState, isA<CodigoQrError>());
    expect(
      (vm.currentState as CodigoQrError).message,
      'Fuera de la zona permitida',
    );
    expect(vm.rotacionAutomatica, isFalse);
  });

  test('un código que llega vencido no entra en bucle', () async {
    repo.vigencia = Duration.zero;

    await vm.generar();

    expect(vm.currentState, isA<CodigoQrError>());
    expect(repo.generados, 1);
  });

  test('anular deja la pantalla en el estado inicial', () async {
    await vm.generar();

    expect(await vm.revocar(), isTrue);
    expect(vm.currentState, isA<CodigoQrInicial>());
    expect(temporizadores.last.cancelado, isTrue);
  });

  test('si anular falla mantiene el código y muestra el aviso', () async {
    await vm.generar();
    repo.fallaAlRevocar = const ServerFailure('No se pudo anular');

    expect(await vm.revocar(), isFalse);
    final estado = vm.currentState as CodigoQrVisible;
    expect(estado.mensaje, 'No se pudo anular');
    expect(estado.revocando, isFalse);
  });

  test('sin código visible no hay nada que anular', () async {
    expect(await vm.revocar(), isFalse);
  });

  test('salir de primer plano cancela las renovaciones del QR', () async {
    await vm.generar();
    vm.suspender();
    expect(temporizadores.single.cancelado, isTrue);
    expect(vm.rotacionAutomatica, isFalse);
    ahora = ahora.add(const Duration(seconds: 31));
    temporizadores.single.sonar();
    await pumpEventQueue();
    expect(repo.generados, 1);
    expect(vm.currentState, isA<CodigoQrInicial>());
  });

  testWidgets(
    'la pantalla suspende el QR al ocultarse y no renueva al volver',
    (tester) async {
      await tester.pumpWidget(MaterialApp(home: CodigoQrPage(viewModel: vm)));
      await vm.generar();
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(vm.currentState, isA<CodigoQrInicial>());
      expect(temporizadores.single.cancelado, isTrue);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(repo.generados, 1);
      // Desmontar cancela la suscripción antes de esperar el cierre del stream.
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  test(
    'no envía coordenadas si la lectura termina fuera de primer plano',
    () async {
      ubicacion.pendiente = Completer<UbicacionDispositivo>();
      final generacion = vm.generar();
      vm.suspender();
      ubicacion.pendiente!.complete(
        UbicacionDispositivo(
          latitud: -18.013,
          longitud: -70.251,
          precisionMetros: 5,
          obtenidaEn: ahora,
        ),
      );
      await generacion;
      expect(repo.generados, 0);
      expect(temporizadores, isEmpty);
      expect(vm.currentState, isA<CodigoQrInicial>());
    },
  );

  test('una respuesta tardía no reactiva el QR después de suspender', () async {
    final pendiente = Completer<void>();
    repo.esperaGeneracion = pendiente.future;
    final generacion = vm.generar();
    await pumpEventQueue();
    expect(repo.generados, 1);
    vm.suspender();
    pendiente.complete();
    await generacion;
    expect(temporizadores, isEmpty);
    expect(vm.currentState, isA<CodigoQrInicial>());
  });
}
