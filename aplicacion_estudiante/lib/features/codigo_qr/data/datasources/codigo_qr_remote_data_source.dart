import '../../../../core/auth/session_token_provider.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/http_gateway.dart';
import '../../../ubicacion/domain/entities/ubicacion_dispositivo.dart';
import '../models/codigo_qr_dto.dart';

abstract interface class CodigoQrRemoteDataSource {
  Future<CodigoQrDto> generar(UbicacionDispositivo ubicacion);

  Future<void> revocarActual();
}

final class CodigoQrRemoteDataSourceImpl implements CodigoQrRemoteDataSource {
  const CodigoQrRemoteDataSourceImpl({
    required HttpGateway httpGateway,
    required SessionTokenProvider sessionTokenProvider,
  }) : _httpGateway = httpGateway,
       _sessionTokenProvider = sessionTokenProvider;

  final HttpGateway _httpGateway;
  final SessionTokenProvider _sessionTokenProvider;

  @override
  Future<CodigoQrDto> generar(UbicacionDispositivo ubicacion) async {
    final response = await _httpGateway.post(
      '/codigos-qr',
      headers: await _autorizacion(),
      body: {'ubicacion': ubicacionToJson(ubicacion)},
    );
    _comprobar(response);
    final datos = response.body?['datos'];
    if (datos is! Map<String, dynamic>) throw const DataFailure();
    return CodigoQrDto.fromJson(datos.cast<String, Object?>());
  }

  @override
  Future<void> revocarActual() async {
    final response = await _httpGateway.delete(
      '/codigos-qr/actual',
      headers: await _autorizacion(),
    );
    _comprobar(response);
  }

  Future<Map<String, String>> _autorizacion() async {
    final token = await _sessionTokenProvider.readAccessToken();
    if (token == null) throw const UnauthorizedFailure();
    return {'Authorization': 'Bearer $token'};
  }

  /// Convierte una respuesta de error en un `Failure` con el mensaje de la API
  /// (por ejemplo, "fuera de la zona permitida").
  void _comprobar(HttpResponseData response) {
    if (response.esExitosa) return;
    final error = response.body?['error'];
    final mensaje = error is Map ? error['mensaje'] as String? : null;
    if (response.statusCode == 401) {
      throw mensaje == null
          ? const UnauthorizedFailure()
          : UnauthorizedFailure(mensaje);
    }
    throw mensaje == null ? const ServerFailure() : ServerFailure(mensaje);
  }
}
