import '../../../../core/auth/secure_session_storage.dart';
import '../repositories/login_estudiante_repository.dart';

final class CerrarSesionUseCase {
  const CerrarSesionUseCase({
    required LoginEstudianteRepository repository,
    required SecureSessionStorage sessionStorage,
    Future<void> Function()? borrarDatosOffline,
  }) : _repository = repository,
       _sessionStorage = sessionStorage,
       _borrarDatosOffline = borrarDatosOffline;

  final LoginEstudianteRepository _repository;
  final SecureSessionStorage _sessionStorage;

  /// Borra la vinculación del QR sin conexión. En la API, cerrar sesión ya
  /// revoca los teléfonos vinculados; aquí se borra la copia local.
  final Future<void> Function()? _borrarDatosOffline;

  Future<void> call() async {
    try {
      await _cerrarEnApi();
    } finally {
      await _borrarDatosOffline?.call();
    }
  }

  Future<void> _cerrarEnApi() async {
    final tokens = await _sessionStorage.leerTokens();
    if (tokens != null) {
      await _repository.cerrarSesion(tokens.tokenAcceso);
    } else {
      await _sessionStorage.limpiar();
    }
  }
}
