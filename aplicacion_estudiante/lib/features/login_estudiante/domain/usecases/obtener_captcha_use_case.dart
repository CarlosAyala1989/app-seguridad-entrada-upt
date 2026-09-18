import '../entities/flujo_login.dart';
import '../repositories/login_estudiante_repository.dart';

final class ObtenerCaptchaUseCase {
  const ObtenerCaptchaUseCase(this._repository);

  final LoginEstudianteRepository _repository;

  Future<CaptchaIntranet> call() {
    return _repository.obtenerCaptcha();
  }
}
