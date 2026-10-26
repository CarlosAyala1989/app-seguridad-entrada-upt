import '../../domain/entities/notificacion.dart';
import '../../domain/repositories/notificaciones_repository.dart';
import '../datasources/notificaciones_remote_data_source.dart';

final class NotificacionesRepositoryImpl implements NotificacionesRepository {
  const NotificacionesRepositoryImpl(this._remote);

  final NotificacionesRemoteDataSource _remote;

  @override
  Future<PaginaNotificaciones> listar({
    required int pagina,
    required int limite,
    TipoNotificacion? tipo,
    bool soloNoLeidas = false,
  }) => _remote.listar(
    pagina: pagina,
    limite: limite,
    tipo: tipo,
    soloNoLeidas: soloNoLeidas,
  );

  @override
  Future<ResumenNotificaciones> resumen() => _remote.resumen();

  @override
  Future<Notificacion> detalle(int id) => _remote.detalle(id);

  @override
  Future<Notificacion> marcarLeida(int id) => _remote.marcarLeida(id);
}
