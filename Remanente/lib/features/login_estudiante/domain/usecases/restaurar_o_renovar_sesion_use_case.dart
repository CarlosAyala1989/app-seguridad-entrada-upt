import '../../../../core/auth/secure_session_storage.dart';
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
  Future<Usuario?> call() async {
    final tokens = await _sessionStorage.leerTokens();
    if (tokens == null) {
      return null;
    }

    if (tokens.renovacionExpirada) {
      await _sessionStorage.limpiar();
      return null;
    }

    if (tokens.accesoExpirado) {
      try {
        final nuevaSesion = await _repository.renovarSesion(
          tokens.tokenRenovacion,
        );
        return nuevaSesion.usuario;
      } catch (_) {
        await _sessionStorage.limpiar();
        return null;
      }
    }

    try {
      return await _repository.consultarSesion(tokens.tokenAcceso);
    } catch (_) {
      try {
        final nuevaSesion = await _repository.renovarSesion(
          tokens.tokenRenovacion,
        );
        return nuevaSesion.usuario;
      } catch (_) {
        await _sessionStorage.limpiar();
        return null;
      }
    }
  }
}
