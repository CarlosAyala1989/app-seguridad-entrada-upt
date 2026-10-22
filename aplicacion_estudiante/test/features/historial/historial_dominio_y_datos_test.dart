import 'package:aplicacion_estudiante/core/auth/session_token_provider.dart';
import 'package:aplicacion_estudiante/core/error/failure.dart';
import 'package:aplicacion_estudiante/core/network/http_gateway.dart';
import 'package:aplicacion_estudiante/features/historial/data/datasources/historial_remote_data_source.dart';
import 'package:aplicacion_estudiante/features/historial/data/models/historial_dto.dart';
import 'package:aplicacion_estudiante/features/historial/data/repositories/historial_repository_impl.dart';
import 'package:aplicacion_estudiante/features/historial/domain/entities/registro_historial.dart';
import 'package:aplicacion_estudiante/features/historial/domain/usecases/obtener_historial_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

/// Respuesta de ejemplo del documento de Carlos (US-14).
final _respuesta = <String, Object?>{
  'datos': [
    {
      'id': 502,
      'usuario_id': 42,
      'resultado': 'DENEGADO',
      'motivo': 'CREDENCIAL_YA_UTILIZADA',
      'registrado_en': '2026-10-18T15:01:00.000Z',
      'punto_acceso': {'id': 3, 'codigo': 'PUERTA-PRINCIPAL', 'nombre': 'Puerta principal'},
    },
    {
      'id': 501,
      'usuario_id': 42,
      'resultado': 'AUTORIZADO',
      'motivo': 'ACCESO_AUTORIZADO',
      'registrado_en': '2026-10-18T15:00:00.000Z',
      'punto_acceso': {'id': 3, 'codigo': 'PUERTA-PRINCIPAL', 'nombre': 'Puerta principal'},
    },
  ],
  'paginacion': {'pagina': 1, 'limite': 20, 'total': 2, 'total_paginas': 1},
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
  String? ruta;
  Map<String, String>? cabeceras;

  @override
  Future<HttpResponseData> get(
    String path, {
    Map<String, String> headers = const {},
    Duration? timeout,
  }) async {
    ruta = path;
    cabeceras = headers;
    return respuesta;
  }

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

RegistroHistorial _registro(ResultadoIngreso r, String motivo) =>
    RegistroHistorial(
      id: 1,
      resultado: r,
      motivo: motivo,
      registradoEn: DateTime.utc(2026, 10, 18, 15),
      puntoAccesoNombre: 'Puerta principal',
    );

void main() {
  group('RegistroHistorial', () {
    test('traduce los motivos conocidos', () {
      expect(
        _registro(ResultadoIngreso.denegado, 'CREDENCIAL_YA_UTILIZADA')
            .motivoLegible,
        'El código QR ya se había usado',
      );
      expect(
        _registro(ResultadoIngreso.autorizado, 'ACCESO_AUTORIZADO').esAutorizado,
        isTrue,
      );
    });

    test('un motivo nuevo usa un texto de respaldo', () {
      expect(
        _registro(ResultadoIngreso.denegado, 'MOTIVO_NUEVO').motivoLegible,
        'Ingreso rechazado',
      );
      expect(
        _registro(ResultadoIngreso.autorizado, 'MOTIVO_NUEVO').motivoLegible,
        'Ingreso autorizado',
      );
    });

    test('hayMas compara la página con el total de páginas', () {
      const ultima = PaginaHistorial(
        registros: [],
        pagina: 2,
        totalPaginas: 2,
        total: 30,
      );
      const primera = PaginaHistorial(
        registros: [],
        pagina: 1,
        totalPaginas: 2,
        total: 30,
      );
      expect(ultima.hayMas, isFalse);
      expect(primera.hayMas, isTrue);
    });
  });

  group('ObtenerHistorialUseCase', () {
    test('rechaza página o límite fuera de lo que acepta la API', () {
      final uc = ObtenerHistorialUseCase(
        HistorialRepositoryImpl(
          HistorialRemoteDataSourceImpl(
            httpGateway: _Gateway(const HttpResponseData(statusCode: 200)),
            sessionTokenProvider: const _Token('t'),
          ),
        ),
      );
      expect(() => uc(pagina: 0), throwsArgumentError);
      expect(() => uc(limite: 101), throwsArgumentError);
      expect(() => uc(limite: 0), throwsArgumentError);
    });
  });

  group('datos', () {
    test('lee la respuesta de ejemplo de la API', () {
      final pagina = paginaHistorialFromJson(_respuesta);
      expect(pagina.total, 2);
      expect(pagina.hayMas, isFalse);
      expect(pagina.registros.first.id, 502);
      expect(pagina.registros.first.esAutorizado, isFalse);
      expect(pagina.registros.first.registradoEn.isUtc, isTrue);
    });

    test('una respuesta incompleta lanza DataFailure', () {
      expect(
        () => paginaHistorialFromJson({'datos': []}),
        throwsA(isA<DataFailure>()),
      );
      expect(
        () => paginaHistorialFromJson({
          'datos': [
            {'id': 1, 'resultado': 'OTRO'},
          ],
          'paginacion': {'pagina': 1, 'total': 1, 'total_paginas': 1},
        }),
        throwsA(isA<DataFailure>()),
      );
    });

    test('la consulta omite el filtro cuando no se usa', () {
      expect(consultaHistorial(pagina: 1, limite: 20), 'pagina=1&limite=20');
      expect(
        consultaHistorial(
          pagina: 2,
          limite: 20,
          resultado: ResultadoIngreso.denegado,
        ),
        'pagina=2&limite=20&resultado=DENEGADO',
      );
    });

    test('llama a /ingresos/historial con el token Bearer', () async {
      final gateway = _Gateway(
        HttpResponseData(statusCode: 200, body: _respuesta),
      );
      final pagina = await ObtenerHistorialUseCase(
        HistorialRepositoryImpl(
          HistorialRemoteDataSourceImpl(
            httpGateway: gateway,
            sessionTokenProvider: const _Token('abc'),
          ),
        ),
      )(resultado: ResultadoIngreso.autorizado);

      expect(
        gateway.ruta,
        '/ingresos/historial?pagina=1&limite=20&resultado=AUTORIZADO',
      );
      expect(gateway.cabeceras, {'Authorization': 'Bearer abc'});
      expect(pagina.registros, hasLength(2));
    });

    test('401 se convierte en UnauthorizedFailure', () async {
      final ds = HistorialRemoteDataSourceImpl(
        httpGateway: _Gateway(
          const HttpResponseData(
            statusCode: 401,
            body: {
              'error': {'codigo': 'TOKEN_ACCESO_INVALIDO', 'mensaje': 'Sesión vencida'},
            },
          ),
        ),
        sessionTokenProvider: const _Token('abc'),
      );
      await expectLater(
        ds.obtenerPagina(pagina: 1, limite: 20),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });

    test('403 muestra el mensaje de la API', () async {
      final ds = HistorialRemoteDataSourceImpl(
        httpGateway: _Gateway(
          const HttpResponseData(
            statusCode: 403,
            body: {
              'error': {
                'codigo': 'USUARIO_NO_HABILITADO',
                'mensaje': 'Tu cuenta no está habilitada.',
              },
            },
          ),
        ),
        sessionTokenProvider: const _Token('abc'),
      );
      await expectLater(
        ds.obtenerPagina(pagina: 1, limite: 20),
        throwsA(
          isA<ServerFailure>().having(
            (f) => f.message,
            'message',
            'Tu cuenta no está habilitada.',
          ),
        ),
      );
    });

    test('sin sesión no llama a la API', () async {
      final gateway = _Gateway(const HttpResponseData(statusCode: 200));
      final ds = HistorialRemoteDataSourceImpl(
        httpGateway: gateway,
        sessionTokenProvider: const _Token(null),
      );
      await expectLater(
        ds.obtenerPagina(pagina: 1, limite: 20),
        throwsA(isA<UnauthorizedFailure>()),
      );
      expect(gateway.ruta, isNull);
    });
  });
}
