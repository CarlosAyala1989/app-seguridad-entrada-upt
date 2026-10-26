import '../../../../core/auth/session_token_provider.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/http_gateway.dart';
import '../models/preparacion_qr_offline_dto.dart';

abstract interface class QrOfflineRemoteDataSource {
  Future<PreparacionQrOfflineDto> preparar({
    required String identificadorDispositivo,
    required String plataforma,
  });
}

final class QrOfflineRemoteDataSourceImpl implements QrOfflineRemoteDataSource {
  const QrOfflineRemoteDataSourceImpl({
    required HttpGateway httpGateway,
    required SessionTokenProvider sessionTokenProvider,
  }) : _httpGateway = httpGateway,
       _sessionTokenProvider = sessionTokenProvider;

  final HttpGateway _httpGateway;
  final SessionTokenProvider _sessionTokenProvider;

  @override
  Future<PreparacionQrOfflineDto> preparar({
    required String identificadorDispositivo,
    required String plataforma,
  }) async {
    final token = await _sessionTokenProvider.readAccessToken();
    if (token == null) throw const UnauthorizedFailure();

    // El cuerpo es estricto: solo estos dos campos. La cuenta sale del Bearer.
    final response = await _httpGateway.post(
      '/codigos-qr/preparar-offline',
      headers: {'Authorization': 'Bearer $token'},
      body: {
        'identificador_dispositivo': identificadorDispositivo,
        'plataforma': plataforma,
      },
    );

    if (!response.esExitosa) {
      final error = response.body?['error'];
      final mensaje = error is Map ? error['mensaje'] as String? : null;
      if (response.statusCode == 401) {
        throw mensaje == null
            ? const UnauthorizedFailure()
            : UnauthorizedFailure(mensaje);
      }
      throw mensaje == null ? const ServerFailure() : ServerFailure(mensaje);
    }

    final datos = response.body?['datos'];
    if (datos is! Map<String, dynamic>) throw const DataFailure();
    return PreparacionQrOfflineDto.fromJson(datos.cast<String, Object?>());
  }
}
