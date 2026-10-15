import '../../../../core/error/failure.dart';

sealed class UbicacionFailure extends Failure {
  const UbicacionFailure(super.message);
}

final class ServicioUbicacionDesactivadoFailure extends UbicacionFailure {
  const ServicioUbicacionDesactivadoFailure([
    super.message =
        'Activa la ubicación del dispositivo para solicitar el código QR.',
  ]);
}

final class PermisoUbicacionDenegadoFailure extends UbicacionFailure {
  const PermisoUbicacionDenegadoFailure([
    super.message =
        'Se necesita permiso de ubicación para comprobar el punto de acceso.',
  ]);
}

final class PermisoUbicacionBloqueadoFailure extends UbicacionFailure {
  const PermisoUbicacionBloqueadoFailure([
    super.message =
        'El permiso de ubicación está bloqueado. Habilítalo en los ajustes '
        'del dispositivo.',
  ]);
}

final class UbicacionNoDisponibleFailure extends UbicacionFailure {
  const UbicacionNoDisponibleFailure([
    super.message =
        'No se obtuvo una ubicación reciente. Inténtalo otra vez en un lugar '
        'con mejor señal.',
  ]);
}

/// La posición llegó, pero es vieja, imprecisa o tiene coordenadas inválidas.
final class UbicacionNoConfiableFailure extends UbicacionFailure {
  const UbicacionNoConfiableFailure([
    super.message =
        'La ubicación obtenida no es confiable. Vuelve a intentarlo.',
  ]);
}
