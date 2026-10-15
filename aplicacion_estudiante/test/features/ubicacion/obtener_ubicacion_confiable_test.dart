import 'package:aplicacion_estudiante/features/ubicacion/domain/entities/ubicacion_dispositivo.dart';
import 'package:aplicacion_estudiante/features/ubicacion/domain/failures/ubicacion_failure.dart';
import 'package:aplicacion_estudiante/features/ubicacion/domain/repositories/ubicacion_repository.dart';
import 'package:aplicacion_estudiante/features/ubicacion/domain/usecases/obtener_ubicacion_confiable_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

final class _RepositorioFijo implements UbicacionRepository {
  _RepositorioFijo(this._resultado);

  final Future<UbicacionDispositivo> Function() _resultado;

  @override
  Future<UbicacionDispositivo> obtenerUbicacionActual() => _resultado();
}

void main() {
  final ahora = DateTime(2026, 10, 15, 12);

  UbicacionDispositivo ubicacion({
    double latitud = -18.013,
    double longitud = -70.251,
    double precision = 8,
    Duration antiguedad = const Duration(seconds: 5),
  }) => UbicacionDispositivo(
    latitud: latitud,
    longitud: longitud,
    precisionMetros: precision,
    obtenidaEn: ahora.subtract(antiguedad),
  );

  ObtenerUbicacionConfiableUseCase casoDeUso(UbicacionDispositivo u) =>
      ObtenerUbicacionConfiableUseCase(
        _RepositorioFijo(() async => u),
        ahora: () => ahora,
      );

  test('devuelve la ubicación cuando es reciente, precisa y válida', () async {
    final u = ubicacion();
    expect(await casoDeUso(u)(), same(u));
  });

  test('rechaza una ubicación de hace más de 2 minutos', () {
    expect(
      casoDeUso(ubicacion(antiguedad: const Duration(minutes: 3)))(),
      throwsA(isA<UbicacionNoConfiableFailure>()),
    );
  });

  test('rechaza una precisión mayor que la que acepta la API', () {
    expect(
      casoDeUso(ubicacion(precision: 20000))(),
      throwsA(isA<UbicacionNoConfiableFailure>()),
    );
  });

  test('rechaza una precisión negativa', () {
    expect(
      casoDeUso(ubicacion(precision: -1))(),
      throwsA(isA<UbicacionNoConfiableFailure>()),
    );
  });

  test('rechaza coordenadas fuera de rango', () {
    expect(
      casoDeUso(ubicacion(latitud: 95))(),
      throwsA(isA<UbicacionNoConfiableFailure>()),
    );
    expect(
      casoDeUso(ubicacion(longitud: -190))(),
      throwsA(isA<UbicacionNoConfiableFailure>()),
    );
  });

  test('propaga el fallo del repositorio (p. ej. permiso denegado)', () {
    final uc = ObtenerUbicacionConfiableUseCase(
      _RepositorioFijo(() async => throw const PermisoUbicacionDenegadoFailure()),
    );
    expect(uc(), throwsA(isA<PermisoUbicacionDenegadoFailure>()));
  });

  test('cada fallo de ubicación explica qué hacer', () {
    const fallos = <UbicacionFailure>[
      ServicioUbicacionDesactivadoFailure(),
      PermisoUbicacionDenegadoFailure(),
      PermisoUbicacionBloqueadoFailure(),
      UbicacionNoDisponibleFailure(),
      UbicacionNoConfiableFailure(),
    ];
    for (final fallo in fallos) {
      expect(fallo.message, isNotEmpty);
    }
    expect(
      const PermisoUbicacionBloqueadoFailure().message,
      contains('ajustes'),
    );
  });
}
