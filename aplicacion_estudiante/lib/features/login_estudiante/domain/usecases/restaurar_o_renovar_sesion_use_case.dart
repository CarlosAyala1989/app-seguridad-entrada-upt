import '../../../../core/auth/secure_session_storage.dart';
import '../../../../core/error/failure.dart';
import '../entities/usuario.dart';
import '../repositories/login_estudiante_repository.dart';

final class RestaurarORenovarSesionUseCase {
  const RestaurarORenovarSesionUseCase({
    required LoginEstudianteRepository repository,
    required SecureSessionStorage sessionStorage,
  }) : _repository = repository,
       _sessionStorage = sessionStorage;

  final LoginEstudianteRepository _repository;
  final SecureSessionStorage _sessionStorage;

  /// Restaura la sesión local si sigue activa, o renueva usando el token de renovación.
  /// Devuelve el [Usuario] autenticado o `null` si no hay sesión válida.
  ///
  /// Sin internet no se borra la sesión: se entra con la cuenta guardada,
  /// para poder mostrar el QR sin conexión. Los datos protegidos se vuelven
  /// a pedir cuando haya red.
  Future<Usuario?> call() async {
    final tokens = await _sessionStorage.leerTokens();
    if (tokens == null) {
      return null;
    }

    if (tokens.renovacionExpirada) {
      await _sessionStorage.limpiar();
      return null;
    }

    try {
      if (tokens.accesoExpirado) {
        return (await _repository.renovarSesion(
          tokens.tokenRenovacion,
        )).usuario;
      }
      try {
        return await _repository.consultarSesion(tokens.tokenAcceso);
      } on NetworkFailure {
        rethrow;
      } catch (_) {
        return (await _repository.renovarSesion(
          tokens.tokenRenovacion,
        )).usuario;
      }
    } on NetworkFailure {
      return _repository.usuarioGuardado();
    } catch (_) {
      await _sessionStorage.limpiar();
      return null;
    }
  }
}
