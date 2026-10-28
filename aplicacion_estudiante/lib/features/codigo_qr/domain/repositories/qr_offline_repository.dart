import '../entities/vinculacion_qr_offline.dart';

abstract interface class QrOfflineRepository {
  /// Vincula este teléfono con la API (requiere internet y sesión vigente)
  /// y guarda la respuesta en el almacenamiento seguro.
  ///
  /// Cada llamada genera un secreto nuevo y reemplaza al guardado.
  Future<VinculacionQrOffline> preparar({required int usuarioId});

  /// Vinculación guardada de [usuarioId], o `null` si no hay o es de otra
  /// cuenta.
  Future<VinculacionQrOffline?> recuperar(int usuarioId);

  /// Borra la vinculación y el identificador del teléfono (al cerrar sesión).
  Future<void> borrar();
}
