import 'dart:async';

import 'package:aplicacion_estudiante/core/error/failure.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/data/datasources/qr_offline_local_data_source.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/data/datasources/qr_offline_remote_data_source.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/data/models/preparacion_qr_offline_dto.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/data/repositories/qr_offline_repository_impl.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/domain/entities/codigo_qr.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/domain/entities/vinculacion_qr_offline.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/domain/failures/qr_offline_failure.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/domain/repositories/codigo_qr_repository.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/domain/repositories/qr_offline_repository.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/domain/usecases/generar_codigo_qr_use_case.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/domain/usecases/qr_offline_use_cases.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/domain/usecases/revocar_codigo_qr_use_case.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/presentation/states/codigo_qr_state.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/presentation/viewmodels/codigo_qr_view_model.dart';
import 'package:aplicacion_estudiante/features/ubicacion/domain/entities/ubicacion_dispositivo.dart';
import 'package:aplicacion_estudiante/features/ubicacion/domain/repositories/ubicacion_repository.dart';
import 'package:aplicacion_estudiante/features/ubicacion/domain/usecases/obtener_ubicacion_confiable_use_case.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Vector público de la guía (secreto de prueba: 32 bytes con valor 0x01).
const _secretoPrueba = 'AQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQE';
const _pasoPrueba = 119341442;
const _qrEsperado =
    'upt_offline_v2.123.119341442.510600.'
    'Iw4NAut3QRiHJ0gAD-EeLHe2m6EYzEql0vZ32X2uLZc';

VinculacionQrOffline _vinculacion({int usuarioId = 7, int desfaseMs = 0}) =>
    VinculacionQrOffline(
      usuarioId: usuarioId,
      dispositivoId: 123,
      secreto: _secretoPrueba,
      periodoSegundos: 15,
      desfaseRelojMs: desfaseMs,
    );

/// Un instante dentro del intervalo del vector de prueba.
DateTime _enPaso(int paso, {int msDentro = 0}) =>
    DateTime.fromMillisecondsSinceEpoch(paso * 15000 + msDentro);

final class _RepoOffline implements QrOfflineRepository {
  VinculacionQrOffline? guardada;
  Failure? fallaAlPreparar;
  int preparaciones = 0;
  bool borrada = false;

  @override
  Future<VinculacionQrOffline> preparar({required int usuarioId}) async {
    final f = fallaAlPreparar;
    if (f != null) throw f;
    preparaciones++;
    return guardada = _vinculacion(usuarioId: usuarioId);
  }

  @override
  Future<VinculacionQrOffline?> recuperar(int usuarioId) async {
    final v = guardada;
    return v != null && v.usuarioId == usuarioId ? v : null;
  }

  @override
  Future<void> borrar() async {
    borrada = true;
    guardada = null;
  }
}

final class _RemotoFalso implements QrOfflineRemoteDataSource {
  String? identificadorRecibido;
  String? plataformaRecibida;

  @override
  Future<PreparacionQrOfflineDto> preparar({
    required String identificadorDispositivo,
    required String plataforma,
  }) async {
    identificadorRecibido = identificadorDispositivo;
    plataformaRecibida = plataforma;
    return PreparacionQrOfflineDto(
      dispositivoId: 123,
      secreto: _secretoPrueba,
      horaServidor: DateTime.utc(2026, 10, 26, 19, 0, 2),
      periodoSegundos: 15,
    );
  }
}

final class _Temporizador implements Timer {
  _Temporizador(this.alSonar);

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

  @override
  Future<UbicacionDispositivo> obtenerUbicacionActual() async =>
      UbicacionDispositivo(
        latitud: -18.013,
        longitud: -70.251,
        precisionMetros: 5,
        obtenidaEn: ahora(),
      );
}

/// API del QR en línea que nunca responde porque no hay internet.
final class _ApiSinRed implements CodigoQrRepository {
  @override
  Future<CodigoQr> generar(UbicacionDispositivo ubicacion) async =>
      throw const NetworkFailure();

  @override
  Future<void> revocarActual() async => throw const NetworkFailure();
}

void main() {
  group('VinculacionQrOffline.generar', () {
    test('reproduce el vector de interoperabilidad de la API', () {
      final codigo = _vinculacion().generar(_enPaso(_pasoPrueba, msDentro: 7));

      expect(codigo.contenido, _qrEsperado);
      expect(codigo.otp, '510600');
      expect(codigo.pasoTiempo, _pasoPrueba);
    });

    test('aplica el desfase del reloj para calcular el intervalo', () {
      // El teléfono va 20 s atrasado respecto del servidor.
      final codigo = _vinculacion(
        desfaseMs: 20000,
      ).generar(_enPaso(_pasoPrueba).subtract(const Duration(seconds: 20)));

      expect(codigo.contenido, _qrEsperado);
    });

    test('dentro del mismo intervalo da el mismo código y luego cambia', () {
      final v = _vinculacion();
      final a = v.generar(_enPaso(_pasoPrueba, msDentro: 1000));
      final b = v.generar(_enPaso(_pasoPrueba, msDentro: 14000));
      final c = v.generar(_enPaso(_pasoPrueba + 1));

      expect(b.contenido, a.contenido);
      expect(c.contenido, isNot(a.contenido));
      expect(c.pasoTiempo, _pasoPrueba + 1);
    });

    test('calcula cuánto le queda al código', () {
      final ahora = _enPaso(_pasoPrueba, msDentro: 5500);
      final codigo = _vinculacion().generar(ahora);

      expect(codigo.expiraEn, _enPaso(_pasoPrueba + 1));
      expect(codigo.segundosRestantes(ahora), 10);
      expect(codigo.segundosRestantes(_enPaso(_pasoPrueba + 2)), 0);
    });
  });

  group('casos de uso del QR sin conexión', () {
    late _RepoOffline repo;

    setUp(() => repo = _RepoOffline());

    test('preparar vincula a la cuenta actual', () async {
      final preparar = PrepararQrOfflineUseCase(
        repository: repo,
        usuarioActual: () async => 7,
      );

      expect(await preparar(), isTrue);
      expect(repo.guardada?.usuarioId, 7);
    });

    test('preparar sin red no borra la vinculación que ya había', () async {
      repo.guardada = _vinculacion();
      repo.fallaAlPreparar = const NetworkFailure();
      final preparar = PrepararQrOfflineUseCase(
        repository: repo,
        usuarioActual: () async => 7,
      );

      expect(await preparar(), isFalse);
      expect(repo.guardada, isNotNull);
    });

    test('preparar sin sesión no llama a la API', () async {
      final preparar = PrepararQrOfflineUseCase(
        repository: repo,
        usuarioActual: () async => null,
      );

      expect(await preparar(), isFalse);
      expect(repo.preparaciones, 0);
    });

    test('obtener devuelve la vinculación guardada de la cuenta', () async {
      repo.guardada = _vinculacion();
      final obtener = ObtenerVinculacionOfflineUseCase(
        repository: repo,
        usuarioActual: () async => 7,
      );

      expect((await obtener()).dispositivoId, 123);
    });

    test('obtener falla si el teléfono no fue vinculado', () async {
      final obtener = ObtenerVinculacionOfflineUseCase(
        repository: repo,
        usuarioActual: () async => 7,
      );

      await expectLater(
        obtener(),
        throwsA(isA<SinVinculacionOfflineFailure>()),
      );
    });

    test('nunca usa la vinculación de otra cuenta', () async {
      repo.guardada = _vinculacion(usuarioId: 99);
      final obtener = ObtenerVinculacionOfflineUseCase(
        repository: repo,
        usuarioActual: () async => 7,
      );

      await expectLater(
        obtener(),
        throwsA(isA<SinVinculacionOfflineFailure>()),
      );
    });

    test('obtener sin sesión falla', () async {
      final obtener = ObtenerVinculacionOfflineUseCase(
        repository: repo,
        usuarioActual: () async => null,
      );

      await expectLater(
        obtener(),
        throwsA(isA<SinVinculacionOfflineFailure>()),
      );
    });
  });

  group('PreparacionQrOfflineDto', () {
    test('lee la respuesta de la API', () {
      final dto = PreparacionQrOfflineDto.fromJson({
        'dispositivo_id': 123,
        'secreto': _secretoPrueba,
        'hora_servidor': '2026-10-26T19:00:00.000Z',
        'periodo_segundos': 15,
      });

      expect(dto.dispositivoId, 123);
      expect(dto.periodoSegundos, 15);
      expect(dto.horaServidor, DateTime.utc(2026, 10, 26, 19));
    });

    test('rechaza un secreto con formato inválido', () {
      expect(
        () => PreparacionQrOfflineDto.fromJson({
          'dispositivo_id': 123,
          'secreto': 'corto',
          'hora_servidor': '2026-10-26T19:00:00.000Z',
          'periodo_segundos': 15,
        }),
        throwsA(isA<DataFailure>()),
      );
    });
  });

  group('QrOfflineRepositoryImpl', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    setUp(() => FlutterSecureStorage.setMockInitialValues({}));

    test('vincula, guarda y calcula el desfase del reloj', () async {
      final remoto = _RemotoFalso();
      final local = QrOfflineLocalDataSource();
      final repo = QrOfflineRepositoryImpl(
        remote: remoto,
        local: local,
        plataforma: 'ANDROID',
        // El teléfono recibe la respuesta 2 s antes de la hora del servidor.
        ahora: () => DateTime.utc(2026, 10, 26, 19),
      );

      final v = await repo.preparar(usuarioId: 7);

      expect(v.desfaseRelojMs, 2000);
      expect(remoto.plataformaRecibida, 'ANDROID');
      expect(
        remoto.identificadorRecibido,
        matches(RegExp(r'^[A-Za-z0-9_-]{43}$')),
      );
      expect((await repo.recuperar(7))?.secreto, _secretoPrueba);
      expect(await repo.recuperar(8), isNull);
    });

    test('el identificador del teléfono se conserva entre llamadas', () async {
      final local = QrOfflineLocalDataSource();

      final primero = await local.identificadorDispositivo();
      expect(await local.identificadorDispositivo(), primero);
    });

    test('al borrar desaparecen la vinculación y el identificador', () async {
      final local = QrOfflineLocalDataSource();
      final repo = QrOfflineRepositoryImpl(
        remote: _RemotoFalso(),
        local: local,
        plataforma: 'ANDROID',
      );
      await repo.preparar(usuarioId: 7);
      final identificador = await local.identificadorDispositivo();

      await repo.borrar();

      expect(await repo.recuperar(7), isNull);
      expect(await local.identificadorDispositivo(), isNot(identificador));
    });
  });

  group('CodigoQrViewModel sin conexión', () {
    late DateTime ahora;
    late _RepoOffline repo;
    late List<_Temporizador> temporizadores;
    late CodigoQrViewModel vm;

    setUp(() {
      ahora = _enPaso(_pasoPrueba, msDentro: 2000);
      repo = _RepoOffline()..guardada = _vinculacion();
      temporizadores = [];
      final api = _ApiSinRed();
      vm = CodigoQrViewModel(
        generarCodigoQr: GenerarCodigoQrUseCase(
          obtenerUbicacion: ObtenerUbicacionConfiableUseCase(
            _Ubicacion(() => ahora),
            ahora: () => ahora,
          ),
          repository: api,
        ),
        revocarCodigoQr: RevocarCodigoQrUseCase(api),
        prepararQrOffline: PrepararQrOfflineUseCase(
          repository: repo,
          usuarioActual: () async => 7,
        ),
        obtenerVinculacionOffline: ObtenerVinculacionOfflineUseCase(
          repository: repo,
          usuarioActual: () async => 7,
        ),
        ahora: () => ahora,
        crearTemporizador: (_, alSonar) {
          final t = _Temporizador(alSonar);
          temporizadores.add(t);
          return t;
        },
      );
    });

    tearDown(() => vm.dispose());

    test('sin internet pasa solo al QR calculado en el teléfono', () async {
      await vm.generar();

      final estado = vm.currentState as CodigoQrOfflineVisible;
      expect(estado.codigo.contenido, _qrEsperado);
      expect(estado.segundosRestantes, 13);
    });

    test('rota el código cada intervalo sin pedir nada a la API', () async {
      await vm.generarSinConexion();
      final primero = (vm.currentState as CodigoQrOfflineVisible).codigo;

      ahora = ahora.add(const Duration(seconds: 15));
      temporizadores.last.sonar();

      final segundo = (vm.currentState as CodigoQrOfflineVisible).codigo;
      expect(segundo.pasoTiempo, primero.pasoTiempo + 1);
      expect(segundo.contenido, isNot(primero.contenido));
    });

    test('sin vinculación explica que hay que conectarse una vez', () async {
      repo.guardada = null;

      await vm.generarSinConexion();

      expect(vm.currentState, isA<CodigoQrError>());
    });

    test('preparar en segundo plano no cambia lo que se muestra', () async {
      await vm.prepararSinConexion();

      expect(repo.preparaciones, 1);
      expect(vm.currentState, isA<CodigoQrInicial>());
    });
  });
}
