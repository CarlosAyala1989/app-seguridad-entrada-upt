import '../entities/notificacion.dart';
import '../repositories/notificaciones_repository.dart';

/// Lista la bandeja respetando los límites de la API
/// (página ≥ 1, límite entre 1 y 100).
final class ObtenerNotificacionesUseCase {
  const ObtenerNotificacionesUseCase(this._repository);

  final NotificacionesRepository _repository;

  Future<PaginaNotificaciones> call({
    int pagina = 1,
    int limite = 20,
    TipoNotificacion? tipo,
    bool soloNoLeidas = false,
  }) {
    if (pagina < 1) throw ArgumentError.value(pagina, 'pagina');
    if (limite < 1 || limite > 100) {
      throw ArgumentError.value(limite, 'limite');
    }
    return _repository.listar(
      pagina: pagina,
      limite: limite,
      tipo: tipo,
      soloNoLeidas: soloNoLeidas,
    );
  }
}

final class ConsultarResumenNotificacionesUseCase {
  const ConsultarResumenNotificacionesUseCase(this._repository);

  final NotificacionesRepository _repository;

  Future<ResumenNotificaciones> call() => _repository.resumen();
}

final class ObtenerDetalleNotificacionUseCase {
  const ObtenerDetalleNotificacionUseCase(this._repository);

  final NotificacionesRepository _repository;

  Future<Notificacion> call(int id) {
    if (id < 1) throw ArgumentError.value(id, 'id');
    return _repository.detalle(id);
  }
}

/// Marca como leída solo si aún no lo está: así no se repite la petición
/// para un aviso que ya se confirmó.
final class MarcarNotificacionLeidaUseCase {
  const MarcarNotificacionLeidaUseCase(this._repository);

  final NotificacionesRepository _repository;

  Future<Notificacion> call(Notificacion notificacion) async {
    if (notificacion.leida) return notificacion;
    return _repository.marcarLeida(notificacion.id);
  }
}
