import '../../../../core/error/failure.dart';
import '../entities/vinculacion_qr_offline.dart';
import '../failures/qr_offline_failure.dart';
import '../repositories/qr_offline_repository.dart';

/// Devuelve el ID de la cuenta con sesión en este teléfono, o `null`.
typedef UsuarioActual = Future<int?> Function();

/// Vincula el teléfono para el QR sin conexión mientras hay internet.
///
/// Se llama al abrir la pantalla del QR. Si no hay red no pasa nada: se sigue
/// usando la vinculación guardada. No se reintenta en bucle, porque cada
/// llamada a la API cambia el secreto.
final class PrepararQrOfflineUseCase {
  const PrepararQrOfflineUseCase({
    required QrOfflineRepository repository,
    required UsuarioActual usuarioActual,
  }) : _repository = repository,
       _usuarioActual = usuarioActual;

  final QrOfflineRepository _repository;
  final UsuarioActual _usuarioActual;

  /// `true` si quedó vinculado; `false` si no se pudo (sin red, sin sesión o
  /// la API lo rechazó). Nunca borra una vinculación que ya funcionaba.
  Future<bool> call() async {
    try {
      final usuarioId = await _usuarioActual();
      if (usuarioId == null) return false;
      await _repository.preparar(usuarioId: usuarioId);
      return true;
    } on Failure {
      return false;
    }
  }
}

/// Obtiene la vinculación guardada para generar el QR sin internet.
final class ObtenerVinculacionOfflineUseCase {
  const ObtenerVinculacionOfflineUseCase({
    required QrOfflineRepository repository,
    required UsuarioActual usuarioActual,
  }) : _repository = repository,
       _usuarioActual = usuarioActual;

  final QrOfflineRepository _repository;
  final UsuarioActual _usuarioActual;

  /// Lanza [SinVinculacionOfflineFailure] si no hay sesión o si este
  /// teléfono no se vinculó antes con conexión.
  Future<VinculacionQrOffline> call() async {
    final usuarioId = await _usuarioActual();
    if (usuarioId == null) throw const SinVinculacionOfflineFailure();
    final vinculacion = await _repository.recuperar(usuarioId);
    if (vinculacion == null) throw const SinVinculacionOfflineFailure();
    return vinculacion;
  }
}
