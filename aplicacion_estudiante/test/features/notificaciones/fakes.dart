import 'package:aplicacion_estudiante/core/error/failure.dart';
import 'package:aplicacion_estudiante/features/notificaciones/domain/entities/notificacion.dart';
import 'package:aplicacion_estudiante/features/notificaciones/domain/repositories/notificaciones_repository.dart';

Notificacion notificacionDePrueba(
  int id, {
  bool alerta = false,
  bool leida = false,
}) => Notificacion(
  id: id,
  registroAccesoId: 500 + id,
  tipo: alerta
      ? TipoNotificacion.intentoSospechoso
      : TipoNotificacion.denegacionAcceso,
  evento: alerta ? 'CREDENCIAL_YA_UTILIZADA' : 'ACCESO_DENEGADO',
  titulo: alerta ? 'Posible uso sospechoso de tu credencial' : 'Ingreso denegado',
  mensaje: 'Se denegó un intento de ingreso con tu identidad.',
  causaGeneral: 'La credencial presentada ya fue utilizada.',
  canalSoporte: 'Acércate al personal de seguridad de la puerta.',
  leida: leida,
  creadaEn: DateTime.utc(2026, 10, 23, 15),
  registradoEn: DateTime.utc(2026, 10, 23, 15),
  puntoAccesoNombre: 'Puerta principal',
  leidaEn: leida ? DateTime.utc(2026, 10, 23, 15, 2) : null,
);

/// Repositorio en memoria para los tests de la bandeja y la campana.
final class RepositorioFalso implements NotificacionesRepository {
  final List<Notificacion> todas = [];
  final paginas = <int, PaginaNotificaciones>{};
  final pedidas = <(int, TipoNotificacion?, bool)>[];
  final marcadas = <int>[];
  int consultasResumen = 0;
  Failure? falla;

  @override
  Future<PaginaNotificaciones> listar({
    required int pagina,
    required int limite,
    TipoNotificacion? tipo,
    bool soloNoLeidas = false,
  }) async {
    pedidas.add((pagina, tipo, soloNoLeidas));
    final f = falla;
    if (f != null) throw f;
    final fija = paginas[pagina];
    if (fija != null) return fija;
    final filtradas = todas
        .where((n) => tipo == null || n.tipo == tipo)
        .where((n) => !soloNoLeidas || !n.leida)
        .toList();
    return PaginaNotificaciones(
      notificaciones: filtradas,
      pagina: pagina,
      totalPaginas: filtradas.isEmpty ? 0 : 1,
      total: filtradas.length,
    );
  }

  @override
  Future<ResumenNotificaciones> resumen() async {
    consultasResumen++;
    final f = falla;
    if (f != null) throw f;
    final pendientes = todas.where((n) => !n.leida);
    final alertas = pendientes.where((n) => n.esAlerta).length;
    return ResumenNotificaciones(
      totalNoLeidas: pendientes.length,
      denegacionesNoLeidas: pendientes.length - alertas,
      alertasNoLeidas: alertas,
    );
  }

  @override
  Future<Notificacion> detalle(int id) async =>
      todas.firstWhere((n) => n.id == id);

  @override
  Future<Notificacion> marcarLeida(int id) async {
    marcadas.add(id);
    final i = todas.indexWhere((n) => n.id == id);
    final leida = notificacionDePrueba(
      id,
      alerta: todas[i].esAlerta,
      leida: true,
    );
    todas[i] = leida;
    return leida;
  }
}
