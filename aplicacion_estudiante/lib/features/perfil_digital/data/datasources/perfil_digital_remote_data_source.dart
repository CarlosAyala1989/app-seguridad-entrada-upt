import '../../../../core/auth/session_token_provider.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/http_gateway.dart';
import '../models/perfil_digital_dto.dart';

abstract interface class PerfilDigitalRemoteDataSource {
  Future<PerfilDigitalDto?> obtenerPerfilActual();
}

final class PerfilDigitalRemoteDataSourceImpl
    implements PerfilDigitalRemoteDataSource {
  const PerfilDigitalRemoteDataSourceImpl({
    required HttpGateway httpGateway,
    required SessionTokenProvider sessionTokenProvider,
  }) : _httpGateway = httpGateway,
       _sessionTokenProvider = sessionTokenProvider;

  final HttpGateway _httpGateway;
  final SessionTokenProvider _sessionTokenProvider;

  @override
  Future<PerfilDigitalDto?> obtenerPerfilActual() async {
    final token = await _sessionTokenProvider.readAccessToken();
    if (token == null) {
      throw const UnauthorizedFailure();
    }
    final response = await _httpGateway.get(
      '/identidad-digital',
      headers: {'Authorization': 'Bearer $token'},
    );

    final body = response.body;
    switch (response.statusCode) {
      case 200:
        final datos = body?['datos'];
        if (datos is! Map<String, dynamic>) {
          throw const DataFailure();
        }
        return PerfilDigitalDto.fromJson(datos.cast<String, Object?>());
      case 204:
        return null;
      case 401:
        throw const UnauthorizedFailure();
      default:
        final error = body?['error'];
        final mensaje = error is Map ? error['mensaje'] as String? : null;
        throw mensaje == null ? const ServerFailure() : ServerFailure(mensaje);
    }
  }
}
