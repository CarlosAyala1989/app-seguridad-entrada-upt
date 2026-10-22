import '../entities/registro_historial.dart';

abstract interface class HistorialRepository {
  /// Pide una página del historial del usuario de la sesión actual.
  /// Con [resultado] `null` devuelve ingresos y rechazos.
  Future<PaginaHistorial> obtenerPagina({
    required int pagina,
    required int limite,
    ResultadoIngreso? resultado,
  });
}
