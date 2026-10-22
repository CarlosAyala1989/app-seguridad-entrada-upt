import '../entities/registro_historial.dart';
import '../repositories/historial_repository.dart';

/// Consulta el historial propio respetando los límites de la API
/// (página ≥ 1, límite entre 1 y 100).
final class ObtenerHistorialUseCase {
  const ObtenerHistorialUseCase(this._repository);

  final HistorialRepository _repository;

  static const limitePorDefecto = 20;

  Future<PaginaHistorial> call({
    int pagina = 1,
    int limite = limitePorDefecto,
    ResultadoIngreso? resultado,
  }) {
    if (pagina < 1) throw ArgumentError.value(pagina, 'pagina');
    if (limite < 1 || limite > 100) {
      throw ArgumentError.value(limite, 'limite');
    }
    return _repository.obtenerPagina(
      pagina: pagina,
      limite: limite,
      resultado: resultado,
    );
  }
}
