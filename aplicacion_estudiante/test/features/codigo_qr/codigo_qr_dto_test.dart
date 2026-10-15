import 'package:aplicacion_estudiante/core/error/failure.dart';
import 'package:aplicacion_estudiante/features/codigo_qr/data/models/codigo_qr_dto.dart';
import 'package:aplicacion_estudiante/features/ubicacion/domain/entities/ubicacion_dispositivo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lee la respuesta de POST /codigos-qr', () {
    final dto = CodigoQrDto.fromJson({
      'codigo_qr': 'abc123',
      'estado': 'PENDIENTE',
      'emitida_en': '2026-10-15T12:00:00Z',
      'expira_en': '2026-10-15T12:00:30Z',
      'duracion_segundos': 30,
      'un_solo_uso': true,
      'ubicacion': {
        'punto_acceso': {'codigo': 'P1', 'nombre': 'Puerta principal'},
      },
    });

    final codigo = dto.toDomain();
    expect(codigo.contenido, 'abc123');
    expect(codigo.duracionSegundos, 30);
    expect(codigo.puntoAccesoNombre, 'Puerta principal');
    expect(codigo.expiraEn.isUtc, isTrue);
  });

  test('sin punto de acceso usa un nombre genérico', () {
    final dto = CodigoQrDto.fromJson({
      'codigo_qr': 'abc123',
      'estado': 'PENDIENTE',
      'emitida_en': '2026-10-15T12:00:00Z',
      'expira_en': '2026-10-15T12:00:30Z',
      'duracion_segundos': 30,
    });
    expect(dto.puntoAccesoNombre, 'Punto de acceso');
    expect(dto.unSoloUso, isTrue);
  });

  test('una respuesta incompleta lanza DataFailure', () {
    expect(
      () => CodigoQrDto.fromJson({'codigo_qr': 'abc123'}),
      throwsA(isA<DataFailure>()),
    );
  });

  test('la ubicación se envía con los nombres que espera la API', () {
    final json = ubicacionToJson(
      UbicacionDispositivo(
        latitud: -18.013,
        longitud: -70.251,
        precisionMetros: 5,
        obtenidaEn: DateTime.utc(2026, 10, 15, 12),
      ),
    );
    expect(json, {
      'latitud': -18.013,
      'longitud': -70.251,
      'precision_metros': 5.0,
      'obtenida_en': '2026-10-15T12:00:00.000Z',
    });
  });
}
