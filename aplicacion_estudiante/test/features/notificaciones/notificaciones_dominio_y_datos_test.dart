import 'package:aplicacion_estudiante/core/auth/session_token_provider.dart';
import 'package:aplicacion_estudiante/core/error/failure.dart';
import 'package:aplicacion_estudiante/core/network/http_gateway.dart';
import 'package:aplicacion_estudiante/features/notificaciones/data/datasources/notificaciones_remote_data_source.dart';
import 'package:aplicacion_estudiante/features/notificaciones/data/models/notificacion_dto.dart';
import 'package:aplicacion_estudiante/features/notificaciones/data/repositories/notificaciones_repository_impl.dart';
import 'package:aplicacion_estudiante/features/notificaciones/domain/entities/notificacion.dart';
import 'package:aplicacion_estudiante/features/notificaciones/domain/usecases/notificaciones_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// Aviso de ejemplo del documento de Carlos (US-20/US-21).
Map<String, Object?> _json({
  int id = 101,
  String tipo = 'DENEGACION_ACCESO',
  String estado = 'NO_LEIDA',
  String? leidaEn,
}) => {
  'id': id,
  'usuario_id': 42,
  'registro_acceso_id': 501,
  'tipo': tipo,
  'evento': tipo == 'DENEGACION_ACCESO'
      ? 'ACCESO_DENEGADO'
      : 'CREDENCIAL_YA_UTILIZADA',
  'titulo': 'Ingreso denegado',
  'mensaje': 'Se denegó un intento de ingreso con tu identidad.',
  'causa_general': 'La credencial presentada ya fue utilizada.',
  'canal_soporte': 'Acércate al personal de seguridad de la puerta.',
  'estado': estado,
  'creada_en': '2026-10-23T15:00:00.124Z',
  'leida_en': leidaEn,
  'registrado_en': '2026-10-23T15:00:00.123Z',
  'punto_acceso': {'id': 3, 'codigo': 'PUERTA-PRINCIPAL', 'nombre': 'Puerta principal'},
};

final class _Token implements SessionTokenProvider {
  const _Token(this.token);

  final String? token;

  @override
  Future<String?> readAccessToken() async => token;
}

final class _Gateway implements HttpGateway {
  _Gateway(this.respuesta);

  final HttpResponseData respuesta;
  final llamadas = <String>[];
  Map<String, String>? cabeceras;

  Future<HttpResponseData> _registrar(String metodo, String path, Map<String, String> h) async {
    llamadas.add('$metodo $path');
    cabeceras = h;
    return respuesta;
  }

  @override
  Future<HttpResponseData> get(
    String path, {
    Map<String, String> headers = const {},
    Duration? timeout,
  }) => _registrar('GET', path, headers);

  @override
  Future<HttpResponseData> patch(
    String path, {
    Map<String, String> headers = const {},
    Map<String, Object?>? body,
    Duration? timeout,
  }) => _registrar('PATCH', path, headers);

  @override
  Future<HttpResponseData> post(
    String path, {
    Map<String, String> headers = const {},
    Map<String, Object?>? body,
    Duration? timeout,
  }) => throw UnimplementedError();

  @override
  Future<HttpResponseData> delete(
    String path, {
    Map<String, String> headers = const {},
    Duration? timeout,
  }) => throw UnimplementedError();
}

NotificacionesRemoteDataSource _remoto(HttpResponseData r, {String? token = 'abc'}) =>
    NotificacionesRemoteDataSource(
      httpGateway: _Gateway(r),
      sessionTokenProvider: _Token(token),
    );

void main() {
  group('dominio', () {
    test('entidades', () {
      expect(notificacionDePrueba(1, alerta: true).esAlerta, isTrue);
      expect(notificacionDePrueba(1).esAlerta, isFalse);
      expect(ResumenNotificaciones.vacio.hayPendientes, isFalse);
      const resumen = ResumenNotificaciones(
        totalNoLeidas: 2,
        denegacionesNoLeidas: 1,
        alertasNoLeidas: 1,
      );
      expect(resumen.hayPendientes, isTrue);
      expect(resumen.hayAlertas, isTrue);
      const pagina = PaginaNotificaciones(
        notificaciones: [],
        pagina: 1,
        totalPaginas: 2,
        total: 25,
      );
      expect(pagina.hayMas, isTrue);
    });

    test('los casos de uso validan lo que acepta la API', () {
      final repo = RepositorioFalso();
      expect(
        () => ObtenerNotificacionesUseCase(repo)(pagina: 0),
        throwsArgumentError,
      );
      expect(
        () => ObtenerNotificacionesUseCase(repo)(limite: 101),
        throwsArgumentError,
      );
      expect(
        () => ObtenerDetalleNotificacionUseCase(repo)(0),
        throwsArgumentError,
      );
    });

    test('marcar como leída no repite la petición si ya lo está', () async {
      final repo = RepositorioFalso()..todas.add(notificacionDePrueba(7));
      final marcar = MarcarNotificacionLeidaUseCase(repo);

      final leida = await marcar(notificacionDePrueba(7));
      expect(leida.leida, isTrue);
      await marcar(leida);

      expect(repo.marcadas, [7]);
    });

    test('resumen y detalle delegan en el repositorio', () async {
      final repo = RepositorioFalso()
        ..todas.addAll([notificacionDePrueba(1), notificacionDePrueba(2, alerta: true)]);
      final resumen = await ConsultarResumenNotificacionesUseCase(repo)();
      expect(resumen.totalNoLeidas, 2);
      expect(resumen.alertasNoLeidas, 1);
      expect((await ObtenerDetalleNotificacionUseCase(repo)(2)).esAlerta, isTrue);
    });
  });

  group('datos', () {
    test('lee un aviso de la API', () {
      final n = notificacionFromJson(_json(tipo: 'INTENTO_SOSPECHOSO'));
      expect(n.id, 101);
      expect(n.registroAccesoId, 501);
      expect(n.esAlerta, isTrue);
      expect(n.leida, isFalse);
      expect(n.leidaEn, isNull);
      expect(n.puntoAccesoNombre, 'Puerta principal');
      expect(n.registradoEn.isUtc, isTrue);
    });

    test('lee un aviso ya leído', () {
      final n = notificacionFromJson(
        _json(estado: 'LEIDA', leidaEn: '2026-10-23T15:02:00.000Z'),
      );
      expect(n.leida, isTrue);
      expect(n.leidaEn, isNotNull);
    });

    test('un tipo desconocido o un campo ausente lanza DataFailure', () {
      expect(
        () => notificacionFromJson(_json(tipo: 'OTRO')),
        throwsA(isA<DataFailure>()),
      );
      expect(
        () => notificacionFromJson({..._json(), 'titulo': null}),
        throwsA(isA<DataFailure>()),
      );
      expect(() => resumenFromJson({'datos': {}}), throwsA(isA<DataFailure>()));
    });

    test('la consulta omite los filtros que no se usan', () {
      expect(consultaNotificaciones(pagina: 1, limite: 20), 'pagina=1&limite=20');
      expect(
        consultaNotificaciones(
          pagina: 1,
          limite: 10,
          tipo: TipoNotificacion.intentoSospechoso,
          soloNoLeidas: true,
        ),
        'pagina=1&limite=10&tipo=INTENTO_SOSPECHOSO&estado=NO_LEIDA',
      );
    });

    test('usa las cuatro rutas con el token Bearer', () async {
      final listaGw = _Gateway(
        HttpResponseData(
          statusCode: 200,
          body: {
            'datos': [_json()],
            'paginacion': {'pagina': 1, 'limite': 20, 'total': 1, 'total_paginas': 1},
          },
        ),
      );
      final repo = NotificacionesRepositoryImpl(
        NotificacionesRemoteDataSource(
          httpGateway: listaGw,
          sessionTokenProvider: const _Token('abc'),
        ),
      );
      final pagina = await repo.listar(pagina: 1, limite: 20);
      expect(pagina.notificaciones.single.id, 101);
      expect(listaGw.llamadas, ['GET /notificaciones?pagina=1&limite=20']);
      expect(listaGw.cabeceras, {'Authorization': 'Bearer abc'});

      final resumenGw = _Gateway(
        const HttpResponseData(
          statusCode: 200,
          body: {
            'datos': {
              'total_no_leidas': 2,
              'denegaciones_no_leidas': 1,
              'alertas_no_leidas': 1,
            },
          },
        ),
      );
      final resumen = await NotificacionesRemoteDataSource(
        httpGateway: resumenGw,
        sessionTokenProvider: const _Token('abc'),
      ).resumen();
      expect(resumen.totalNoLeidas, 2);
      expect(resumenGw.llamadas, ['GET /notificaciones/resumen']);

      final detalleGw = _Gateway(
        HttpResponseData(
          statusCode: 200,
          body: {'datos': _json(estado: 'LEIDA', leidaEn: '2026-10-23T15:02:00.000Z')},
        ),
      );
      final remoto = NotificacionesRemoteDataSource(
        httpGateway: detalleGw,
        sessionTokenProvider: const _Token('abc'),
      );
      await remoto.detalle(101);
      final leida = await remoto.marcarLeida(101);
      expect(leida.leida, isTrue);
      expect(detalleGw.llamadas, [
        'GET /notificaciones/101',
        'PATCH /notificaciones/101/leida',
      ]);
    });

    test('404 de un aviso ajeno muestra el mensaje de la API', () async {
      final remoto = _remoto(
        const HttpResponseData(
          statusCode: 404,
          body: {
            'error': {
              'codigo': 'NOTIFICACION_NO_ENCONTRADA',
              'mensaje': 'La notificación solicitada no existe.',
            },
          },
        ),
      );
      await expectLater(
        remoto.detalle(999),
        throwsA(
          isA<ServerFailure>().having(
            (f) => f.message,
            'message',
            'La notificación solicitada no existe.',
          ),
        ),
      );
    });

    test('401 y falta de sesión son UnauthorizedFailure', () async {
      await expectLater(
        _remoto(const HttpResponseData(statusCode: 401)).resumen(),
        throwsA(isA<UnauthorizedFailure>()),
      );
      await expectLater(
        _remoto(const HttpResponseData(statusCode: 200), token: null).resumen(),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });
  });
}
