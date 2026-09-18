import '../entities/flujo_login.dart';
import '../repositories/login_estudiante_repository.dart';

final class VerificarIntranetUseCase {
  const VerificarIntranetUseCase(this._repository);

  final LoginEstudianteRepository _repository;

  Future<VerificacionIntranet> call({
    required String transaccionId,
    required String codigo,
    required String contrasena,
    required String captcha,
  }) {
    return _repository.verificarIntranet(
      transaccionId: transaccionId,
      codigo: codigo,
      contrasena: contrasena,
      captcha: captcha,
    );
  }
}
