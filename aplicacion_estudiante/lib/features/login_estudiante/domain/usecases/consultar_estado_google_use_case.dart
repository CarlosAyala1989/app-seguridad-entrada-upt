import '../entities/flujo_login.dart';
import '../repositories/login_estudiante_repository.dart';

final class ConsultarEstadoGoogleUseCase {
  const ConsultarEstadoGoogleUseCase(this._repository);

  final LoginEstudianteRepository _repository;

  Future<ResultadoEstadoGoogle> call(String transaccionId) {
    return _repository.consultarEstadoGoogle(transaccionId);
  }
}
