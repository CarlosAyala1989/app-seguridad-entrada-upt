import '../../../../shared/utils/input_sanitizer.dart';
import '../entities/flujo_login.dart';
import '../failures/login_failure.dart';
import '../repositories/login_estudiante_repository.dart';

final class VerificarIntranetUseCase {
  const VerificarIntranetUseCase(this._repository);

  final LoginEstudianteRepository _repository;

  Future<VerificacionIntranet> call({
    required String transaccionId,
    required String codigo,
    required String contrasena,
    required String captcha,
  }) async {
    final codigoLimpio = InputSanitizer.sanitizeCodigo(codigo);

    // Validación de negocio previa a la capa de red: si no cumple,
    // se aborta con excepción controlada y NO se invoca al repositorio.
    if (!InputSanitizer.esCodigoInstitucionalValido(codigoLimpio)) {
      throw const CodigoInvalidoFailure();
    }

    return _repository.verificarIntranet(
      transaccionId: transaccionId,
      codigo: codigoLimpio,
      contrasena: contrasena,
      captcha: captcha,
    );
  }
}