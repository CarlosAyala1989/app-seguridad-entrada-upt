import '../../../../core/error/failure.dart';
import '../../domain/entities/notificacion.dart';

/// Lee una notificación de la API. Cualquier campo obligatorio ausente o con
/// otro tipo lanza `DataFailure`.
Notificacion notificacionFromJson(Object? json) {
  if (json is! Map) throw const DataFailure();

  String texto(String clave) {
    final valor = json[clave];
    if (valor is! String) throw const DataFailure();
    return valor;
  }

  int entero(String clave) {
    final valor = json[clave];
    if (valor is! int) throw const DataFailure();
    return valor;
  }

  DateTime fecha(String clave) {
    final valor = DateTime.tryParse('${json[clave]}');
    if (valor == null) throw const DataFailure();
    return valor;
  }

  final tipo = switch (json['tipo']) {
    'DENEGACION_ACCESO' => TipoNotificacion.denegacionAcceso,
    'INTENTO_SOSPECHOSO' => TipoNotificacion.intentoSospechoso,
    _ => throw const DataFailure(),
  };
  final punto = json['punto_acceso'];
  final nombrePunto = punto is Map ? punto['nombre'] : null;
  if (nombrePunto is! String) throw const DataFailure();
  final leidaEn = json['leida_en'];

  return Notificacion(
    id: entero('id'),
    registroAccesoId: entero('registro_acceso_id'),
    tipo: tipo,
    evento: texto('evento'),
    titulo: texto('titulo'),
    mensaje: texto('mensaje'),
    causaGeneral: texto('causa_general'),
    canalSoporte: texto('canal_soporte'),
    leida: texto('estado') == 'LEIDA',
    creadaEn: fecha('creada_en'),
    registradoEn: fecha('registrado_en'),
    puntoAccesoNombre: nombrePunto,
    leidaEn: leidaEn == null ? null : DateTime.tryParse('$leidaEn'),
  );
}

/// Lee `GET /notificaciones` (`datos` + `paginacion`).
PaginaNotificaciones paginaNotificacionesFromJson(Map<String, Object?> json) {
  final datos = json['datos'];
  final paginacion = json['paginacion'];
  if (datos is! List || paginacion is! Map) throw const DataFailure();
  final pagina = paginacion['pagina'];
  final totalPaginas = paginacion['total_paginas'];
  final total = paginacion['total'];
  if (pagina is! int || totalPaginas is! int || total is! int) {
    throw const DataFailure();
  }
  return PaginaNotificaciones(
    notificaciones: [for (final item in datos) notificacionFromJson(item)],
    pagina: pagina,
    totalPaginas: totalPaginas,
    total: total,
  );
}

/// Lee `GET /notificaciones/resumen`.
ResumenNotificaciones resumenFromJson(Map<String, Object?> json) {
  final datos = json['datos'];
  if (datos is! Map) throw const DataFailure();
  final total = datos['total_no_leidas'];
  final denegaciones = datos['denegaciones_no_leidas'];
  final alertas = datos['alertas_no_leidas'];
  if (total is! int || denegaciones is! int || alertas is! int) {
    throw const DataFailure();
  }
  return ResumenNotificaciones(
    totalNoLeidas: total,
    denegacionesNoLeidas: denegaciones,
    alertasNoLeidas: alertas,
  );
}

/// Parámetros de consulta: los filtros que no se usan se omiten.
String consultaNotificaciones({
  required int pagina,
  required int limite,
  TipoNotificacion? tipo,
  bool soloNoLeidas = false,
}) => Uri(
  queryParameters: {
    'pagina': '$pagina',
    'limite': '$limite',
    if (tipo != null)
      'tipo': tipo == TipoNotificacion.denegacionAcceso
          ? 'DENEGACION_ACCESO'
          : 'INTENTO_SOSPECHOSO',
    if (soloNoLeidas) 'estado': 'NO_LEIDA',
  },
).query;
