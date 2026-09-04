import '../../../../core/error/failure.dart';
import '../entities/perfil_digital.dart';
import '../repositories/perfil_digital_repository.dart';

final class ObtenerPerfilDigital {
  const ObtenerPerfilDigital(this._repository);

  final PerfilDigitalRepository _repository;

  Future<PerfilDigital?> call() async {
    final perfil = await _repository.obtenerPerfilActual();
    if (perfil != null && !perfil.tieneDatosMinimos) {
      throw const DataFailure();
    }
    return perfil;
  }
}
