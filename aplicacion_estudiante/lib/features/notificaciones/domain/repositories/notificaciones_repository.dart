import '../entities/notificacion.dart';

/// Bandeja personal del usuario de la sesión: la API nunca devuelve avisos
/// de otra persona.
abstract interface class NotificacionesRepository {
  Future<PaginaNotificaciones> listar({
    required int pagina,
    required int limite,
    TipoNotificacion? tipo,
    bool soloNoLeidas = false,
  });

  Future<ResumenNotificaciones> resumen();

  Future<Notificacion> detalle(int id);

  /// Confirma la lectura. Es idempotente: repetirla no cambia la fecha.
  Future<Notificacion> marcarLeida(int id);
}
