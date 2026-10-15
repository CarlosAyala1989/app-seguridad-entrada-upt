import '../entities/ubicacion_dispositivo.dart';

abstract interface class UbicacionRepository {
  /// Pide permiso si hace falta y devuelve la posición actual.
  ///
  /// Lanza un `UbicacionFailure` si el servicio está apagado, el permiso
  /// se niega o no se obtiene una posición a tiempo.
  Future<UbicacionDispositivo> obtenerUbicacionActual();
}
