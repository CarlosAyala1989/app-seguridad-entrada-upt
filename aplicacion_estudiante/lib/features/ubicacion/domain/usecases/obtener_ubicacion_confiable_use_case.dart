import '../entities/ubicacion_dispositivo.dart';
import '../failures/ubicacion_failure.dart';
import '../repositories/ubicacion_repository.dart';

/// Obtiene la ubicación y rechaza la que no sirve para emitir una credencial.
///
/// La validación de la zona permitida la hace el backend con las coordenadas
/// configuradas en el sistema; aquí solo se descarta lo que es claramente
/// inválido antes de enviarlo.
final class ObtenerUbicacionConfiableUseCase {
  const ObtenerUbicacionConfiableUseCase(
    this._repository, {
    DateTime Function()? ahora,
    this.antiguedadMaxima = const Duration(minutes: 2),
    this.precisionMaximaMetros = 10000,
  }) : _ahora = ahora;

  final UbicacionRepository _repository;
  final DateTime Function()? _ahora;
  final Duration antiguedadMaxima;

  /// Mismo límite que acepta la API (`precision_metros` ≤ 10 000).
  final double precisionMaximaMetros;

  Future<UbicacionDispositivo> call() async {
    final ubicacion = await _repository.obtenerUbicacionActual();
    final ahora = (_ahora ?? DateTime.now)();
    final confiable =
        ubicacion.coordenadasValidas &&
        ubicacion.precisionMetros >= 0 &&
        ubicacion.precisionMetros <= precisionMaximaMetros &&
        ubicacion.esReciente(ahora, antiguedadMaxima);
    if (!confiable) throw const UbicacionNoConfiableFailure();
    return ubicacion;
  }
}
