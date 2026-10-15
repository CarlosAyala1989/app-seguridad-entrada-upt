import '../../../../core/error/failure.dart';
import '../../../ubicacion/domain/entities/ubicacion_dispositivo.dart';
import '../../domain/entities/codigo_qr.dart';

/// Lee la respuesta de `POST /codigos-qr` (campo `datos`).
final class CodigoQrDto {
  const CodigoQrDto({
    required this.codigoQr,
    required this.estado,
    required this.emitidaEn,
    required this.expiraEn,
    required this.duracionSegundos,
    required this.unSoloUso,
    required this.puntoAccesoNombre,
  });

  factory CodigoQrDto.fromJson(Map<String, Object?> json) {
    final codigo = json['codigo_qr'];
    final estado = json['estado'];
    final emitida = DateTime.tryParse('${json['emitida_en']}');
    final expira = DateTime.tryParse('${json['expira_en']}');
    final duracion = json['duracion_segundos'];
    if (codigo is! String ||
        codigo.isEmpty ||
        estado is! String ||
        emitida == null ||
        expira == null ||
        duracion is! int) {
      throw const DataFailure();
    }
    final ubicacion = json['ubicacion'];
    final punto = ubicacion is Map ? ubicacion['punto_acceso'] : null;
    final nombre = punto is Map ? punto['nombre'] : null;
    final unSoloUso = json['un_solo_uso'];
    return CodigoQrDto(
      codigoQr: codigo,
      estado: estado,
      emitidaEn: emitida,
      expiraEn: expira,
      duracionSegundos: duracion,
      unSoloUso: unSoloUso is bool ? unSoloUso : true,
      puntoAccesoNombre: nombre is String ? nombre : 'Punto de acceso',
    );
  }

  final String codigoQr;
  final String estado;
  final DateTime emitidaEn;
  final DateTime expiraEn;
  final int duracionSegundos;
  final bool unSoloUso;
  final String puntoAccesoNombre;

  CodigoQr toDomain() => CodigoQr(
    contenido: codigoQr,
    estado: estado,
    emitidoEn: emitidaEn,
    expiraEn: expiraEn,
    duracionSegundos: duracionSegundos,
    unSoloUso: unSoloUso,
    puntoAccesoNombre: puntoAccesoNombre,
  );
}

/// Cuerpo `ubicacion` que espera la API.
Map<String, Object?> ubicacionToJson(UbicacionDispositivo u) => {
  'latitud': u.latitud,
  'longitud': u.longitud,
  'precision_metros': u.precisionMetros,
  'obtenida_en': u.obtenidaEn.toUtc().toIso8601String(),
};
