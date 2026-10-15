import 'package:aplicacion_estudiante/core/error/failure.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/domain/entities/codigo_qr.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/domain/repositories/codigo_qr_repository.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/domain/usecases/generar_codigo_qr_use_case.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/domain/usecases/revocar_codigo_qr_use_case.dart';
import 'package:aplicacion_estudiante/features/ubicacion/domain/entities/ubicacion_dispositivo.dart';
import 'package:aplicacion_estudiante/features/ubicacion/domain/failures/ubicacion_failure.dart';
import 'package:aplicacion_estudiante/features/ubicacion/domain/repositories/ubicacion_repository.dart';
import 'package:aplicacion_estudiante/features/ubicacion/domain/usecases/obtener_ubicacion_confiable_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

final _ahora = DateTime(2026, 10, 15, 12);

CodigoQr _codigo({Duration vence = const Duration(seconds: 30)}) => CodigoQr(
  contenido: 'token-opaco',
  estado: 'PENDIENTE',
  emitidoEn: _ahora,
  expiraEn: _ahora.add(vence),
  duracionSegundos: 30,
  unSoloUso: true,
  puntoAccesoNombre: 'Puerta principal',
);

final class _Ubicacion implements UbicacionRepository {
  _Ubicacion({this.falla});

  final UbicacionFailure? falla;

  @override
  Future<UbicacionDispositivo> obtenerUbicacionActual() async {
    final f = falla;
    if (f != null) throw f;
    return UbicacionDispositivo(
      latitud: -18.013,
      longitud: -70.251,
      precisionMetros: 5,
      obtenidaEn: _ahora,
    );
  }
}

final class _Repositorio implements CodigoQrRepository {
  UbicacionDispositivo? ubicacionRecibida;
  int revocaciones = 0;

  @override
  Future<CodigoQr> generar(UbicacionDispositivo ubicacion) async {
    ubicacionRecibida = ubicacion;
    return _codigo();
  }

  @override
  Future<void> revocarActual() async => revocaciones++;
}

void main() {
  group('CodigoQr', () {
    test('cuenta los segundos restantes redondeando hacia arriba', () {
      final c = _codigo();
      expect(c.segundosRestantes(_ahora), 30);
      expect(
        c.segundosRestantes(_ahora.add(const Duration(milliseconds: 29100))),
        1,
      );
      expect(c.estaVigente(_ahora), isTrue);
    });

    test('vencido devuelve 0 y deja de estar vigente', () {
      final c = _codigo();
      expect(c.segundosRestantes(_ahora.add(const Duration(minutes: 1))), 0);
      expect(c.estaVigente(_ahora.add(const Duration(seconds: 30))), isFalse);
    });
  });

  group('GenerarCodigoQrUseCase', () {
    test('envía la ubicación obtenida al pedir el código', () async {
      final repo = _Repositorio();
      final generar = GenerarCodigoQrUseCase(
        obtenerUbicacion: ObtenerUbicacionConfiableUseCase(
          _Ubicacion(),
          ahora: () => _ahora,
        ),
        repository: repo,
      );

      final codigo = await generar();

      expect(codigo.contenido, 'token-opaco');
      expect(repo.ubicacionRecibida?.latitud, -18.013);
    });

    test('si falla la ubicación no llama a la API', () async {
      final repo = _Repositorio();
      final generar = GenerarCodigoQrUseCase(
        obtenerUbicacion: ObtenerUbicacionConfiableUseCase(
          _Ubicacion(falla: const PermisoUbicacionDenegadoFailure()),
        ),
        repository: repo,
      );

      await expectLater(generar(), throwsA(isA<Failure>()));
      expect(repo.ubicacionRecibida, isNull);
    });
  });

  test('RevocarCodigoQrUseCase anula el código actual', () async {
    final repo = _Repositorio();
    await RevocarCodigoQrUseCase(repo)();
    expect(repo.revocaciones, 1);
  });
}
