import '../../domain/entities/notificacion.dart';

sealed class BandejaState {
  const BandejaState();
}

final class BandejaCargando extends BandejaState {
  const BandejaCargando();
}

final class BandejaDatos extends BandejaState {
  const BandejaDatos({
    required this.notificaciones,
    required this.hayMas,
    this.cargandoMas = false,
    this.mensaje,
  });

  final List<Notificacion> notificaciones;
  final bool hayMas;
  final bool cargandoMas;
  final String? mensaje;
}

final class BandejaVacia extends BandejaState {
  const BandejaVacia();
}

final class BandejaError extends BandejaState {
  const BandejaError(this.message);

  final String message;
}
