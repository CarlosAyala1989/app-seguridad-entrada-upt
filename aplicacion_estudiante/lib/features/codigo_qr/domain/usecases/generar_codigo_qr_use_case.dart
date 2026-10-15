import '../../../ubicacion/domain/usecases/obtener_ubicacion_confiable_use_case.dart';
import '../entities/codigo_qr.dart';
import '../repositories/codigo_qr_repository.dart';

/// Obtiene la ubicación vigente y con ella pide un QR nuevo a la API.
///
/// Si la ubicación falla, no se llama a la API: nunca se muestra un QR
/// emitido sin ubicación.
final class GenerarCodigoQrUseCase {
  const GenerarCodigoQrUseCase({
    required ObtenerUbicacionConfiableUseCase obtenerUbicacion,
    required CodigoQrRepository repository,
  }) : _obtenerUbicacion = obtenerUbicacion,
       _repository = repository;

  final ObtenerUbicacionConfiableUseCase _obtenerUbicacion;
  final CodigoQrRepository _repository;

  Future<CodigoQr> call() async {
    final ubicacion = await _obtenerUbicacion();
    return _repository.generar(ubicacion);
  }
}
