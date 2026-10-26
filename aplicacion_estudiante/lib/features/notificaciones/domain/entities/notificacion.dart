enum TipoNotificacion {
  /// US-20: se denegó un intento de ingreso con tu identidad.
  denegacionAcceso,

  /// US-21: además, el intento tiene señales de posible uso sospechoso.
  intentoSospechoso,
}

/// Aviso de la bandeja personal. Los textos ya vienen listos de la API.
final class Notificacion {
  const Notificacion({
    required this.id,
    required this.registroAccesoId,
    required this.tipo,
    required this.evento,
    required this.titulo,
    required this.mensaje,
    required this.causaGeneral,
    required this.canalSoporte,
    required this.leida,
    required this.creadaEn,
    required this.registradoEn,
    required this.puntoAccesoNombre,
    this.leidaEn,
  });

  final int id;

  /// Intento de acceso del que nace el aviso. Una alerta y su denegación
  /// comparten este valor.
  final int registroAccesoId;
  final TipoNotificacion tipo;
  final String evento;
  final String titulo;
  final String mensaje;
  final String causaGeneral;

  /// Texto (no necesariamente una URL) con a quién acudir.
  final String canalSoporte;
  final bool leida;
  final DateTime creadaEn;

  /// Momento del intento de ingreso.
  final DateTime registradoEn;
  final String puntoAccesoNombre;
  final DateTime? leidaEn;

  bool get esAlerta => tipo == TipoNotificacion.intentoSospechoso;
}

final class PaginaNotificaciones {
  const PaginaNotificaciones({
    required this.notificaciones,
    required this.pagina,
    required this.totalPaginas,
    required this.total,
  });

  final List<Notificacion> notificaciones;
  final int pagina;
  final int totalPaginas;
  final int total;

  bool get hayMas => pagina < totalPaginas;
}

/// Contadores de avisos sin leer, para la campana.
final class ResumenNotificaciones {
  const ResumenNotificaciones({
    required this.totalNoLeidas,
    required this.denegacionesNoLeidas,
    required this.alertasNoLeidas,
  });

  static const vacio = ResumenNotificaciones(
    totalNoLeidas: 0,
    denegacionesNoLeidas: 0,
    alertasNoLeidas: 0,
  );

  final int totalNoLeidas;
  final int denegacionesNoLeidas;
  final int alertasNoLeidas;

  bool get hayPendientes => totalNoLeidas > 0;
  bool get hayAlertas => alertasNoLeidas > 0;
}
