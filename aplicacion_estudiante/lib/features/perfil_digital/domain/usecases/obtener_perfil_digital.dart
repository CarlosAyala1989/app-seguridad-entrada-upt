import '../entities/perfil_digital.dart';
import '../repositories/perfil_digital_repository.dart';

final class ObtenerPerfilDigital {
  const ObtenerPerfilDigital(this._repository);

  final PerfilDigitalRepository _repository;

  Future<PerfilDigital?> call() => _repository.obtenerPerfilActual();
}
