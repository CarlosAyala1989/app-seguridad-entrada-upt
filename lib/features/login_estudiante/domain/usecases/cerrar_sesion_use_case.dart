import '../../../../core/auth/secure_session_storage.dart';
import '../repositories/login_estudiante_repository.dart';

final class CerrarSesionUseCase {
  const CerrarSesionUseCase({
    required LoginEstudianteRepository repository,
    required SecureSessionStorage sessionStorage,
  }) : _repository = repository,
       _sessionStorage = sessionStorage;

  final LoginEstudianteRepository _repository;
  final SecureSessionStorage _sessionStorage;

  Future<void> call() async {
    final tokens = await _sessionStorage.leerTokens();
    if (tokens != null) {
      await _repository.cerrarSesion(tokens.tokenAcceso);
    } else {
      await _sessionStorage.limpiar();
    }
  }
}
