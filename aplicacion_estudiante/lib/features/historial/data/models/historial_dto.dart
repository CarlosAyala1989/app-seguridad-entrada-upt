import '../../../../core/error/failure.dart';
import '../../domain/entities/registro_historial.dart';

/// Lee la respuesta de `GET /ingresos/historial` (`datos` + `paginacion`).
PaginaHistorial paginaHistorialFromJson(Map<String, Object?> json) {
  final datos = json['datos'];
  final paginacion = json['paginacion'];
  if (datos is! List || paginacion is! Map) throw const DataFailure();

  int entero(Object? valor) {
    if (valor is! int) throw const DataFailure();
    return valor;
  }

  return PaginaHistorial(
    registros: [for (final item in datos) _registro(item)],
    pagina: entero(paginacion['pagina']),
    totalPaginas: entero(paginacion['total_paginas']),
    total: entero(paginacion['total']),
  );
}

RegistroHistorial _registro(Object? item) {
  if (item is! Map) throw const DataFailure();
  final id = item['id'];
  final resultado = switch (item['resultado']) {
    'AUTORIZADO' => ResultadoIngreso.autorizado,
    'DENEGADO' => ResultadoIngreso.denegado,
    _ => null,
  };
  final motivo = item['motivo'];
  final fecha = DateTime.tryParse('${item['registrado_en']}');
  final punto = item['punto_acceso'];
  final nombre = punto is Map ? punto['nombre'] : null;
  if (id is! int ||
      resultado == null ||
      motivo is! String ||
      fecha == null ||
      nombre is! String) {
    throw const DataFailure();
  }
  return RegistroHistorial(
    id: id,
    resultado: resultado,
    motivo: motivo,
    registradoEn: fecha,
    puntoAccesoNombre: nombre,
  );
}

/// Parámetros de consulta: los que no se usan se omiten, como pide la API.
String consultaHistorial({
  required int pagina,
  required int limite,
  ResultadoIngreso? resultado,
}) => Uri(
  queryParameters: {
    'pagina': '$pagina',
    'limite': '$limite',
    if (resultado != null)
      'resultado': resultado == ResultadoIngreso.autorizado
          ? 'AUTORIZADO'
          : 'DENEGADO',
  },
).query;
