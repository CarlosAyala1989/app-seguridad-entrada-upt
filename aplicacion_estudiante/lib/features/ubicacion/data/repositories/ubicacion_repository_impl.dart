import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../domain/entities/ubicacion_dispositivo.dart';
import '../../domain/failures/ubicacion_failure.dart';
import '../../domain/repositories/ubicacion_repository.dart';

/// Lee el GPS del dispositivo con `geolocator`.
final class UbicacionRepositoryImpl implements UbicacionRepository {
  const UbicacionRepositoryImpl();

  @override
  Future<UbicacionDispositivo> obtenerUbicacionActual() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const ServicioUbicacionDesactivadoFailure();
    }

    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso == LocationPermission.denied) {
      throw const PermisoUbicacionDenegadoFailure();
    }
    if (permiso == LocationPermission.deniedForever) {
      throw const PermisoUbicacionBloqueadoFailure();
    }

    try {
      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return UbicacionDispositivo(
        latitud: posicion.latitude,
        longitud: posicion.longitude,
        precisionMetros: posicion.accuracy,
        obtenidaEn: posicion.timestamp,
      );
    } on TimeoutException {
      throw const UbicacionNoDisponibleFailure();
    } on LocationServiceDisabledException {
      throw const ServicioUbicacionDesactivadoFailure();
    } on PermissionDeniedException {
      throw const PermisoUbicacionDenegadoFailure();
    } catch (_) {
      throw const UbicacionNoDisponibleFailure();
    }
  }
}

/// Solo para desarrollo: devuelve una posición fija dentro del campus para
/// probar el QR sin estar en la universidad. Se activa con
/// `--dart-define=UBICACION_SIMULADA=true` y únicamente en modo debug.
final class UbicacionSimuladaRepository implements UbicacionRepository {
  const UbicacionSimuladaRepository();

  static const activada = bool.fromEnvironment('UBICACION_SIMULADA');

  @override
  Future<UbicacionDispositivo> obtenerUbicacionActual() async {
    return UbicacionDispositivo(
      latitud: -18.013,
      longitud: -70.251,
      precisionMetros: 5,
      obtenidaEn: DateTime.now(),
    );
  }
}
