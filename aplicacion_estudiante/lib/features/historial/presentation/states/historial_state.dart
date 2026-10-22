import '../../domain/entities/registro_historial.dart';

sealed class HistorialState {
  const HistorialState();
}

final class HistorialCargando extends HistorialState {
  const HistorialCargando();
}

final class HistorialDatos extends HistorialState {
  const HistorialDatos({
    required this.registros,
    required this.hayMas,
    this.cargandoMas = false,
    this.mensaje,
  });

  final List<RegistroHistorial> registros;
  final bool hayMas;
  final bool cargandoMas;

  /// Aviso si falló la carga de la página siguiente (la lista se conserva).
  final String? mensaje;
}

final class HistorialVacio extends HistorialState {
  const HistorialVacio();
}

final class HistorialError extends HistorialState {
  const HistorialError(this.message);

  final String message;
}
