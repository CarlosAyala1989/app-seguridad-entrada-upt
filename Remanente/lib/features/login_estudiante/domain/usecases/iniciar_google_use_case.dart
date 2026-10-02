import '../entities/flujo_login.dart';
import '../repositories/login_estudiante_repository.dart';

final class IniciarGoogleUseCase {
  const IniciarGoogleUseCase(this._repository);

  final LoginEstudianteRepository _repository;

  Future<AutorizacionGoogle> call({required String verificacionIntranetId}) {
    return _repository.iniciarGoogle(
      verificacionIntranetId: verificacionIntranetId,
    );
  }
}
