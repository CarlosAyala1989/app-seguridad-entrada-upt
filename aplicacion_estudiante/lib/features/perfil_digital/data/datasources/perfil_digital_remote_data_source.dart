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
  })  : _httpGateway = httpGateway,
        _sessionTokenProvider = sessionTokenProvider;

  final HttpGateway _httpGateway;
  final SessionTokenProvider _sessionTokenProvider;

  @override
  Future<PerfilDigitalDto?> obtenerPerfilActual() async {
    final token = await _sessionTokenProvider.readAccessToken();
    final response = await _httpGateway.get(
      '/api/v1/users/me/profile',
      headers: token == null ? const {} : {'Authorization': 'Bearer $token'},
    );

    switch (response.statusCode) {
      case 200:
        final data = response.body?['data'];
        if (data is! Map<String, dynamic>) {
          throw const DataFailure();
        }
        return PerfilDigitalDto.fromJson(data.cast<String, Object?>());
      case 204:
        return null;
      case 401:
        throw const UnauthorizedFailure();
      default:
        throw const ServerFailure();
    }
  }
}
