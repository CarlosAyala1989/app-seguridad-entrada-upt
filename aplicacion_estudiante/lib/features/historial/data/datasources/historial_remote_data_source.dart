import '../../../../core/auth/session_token_provider.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/http_gateway.dart';
import '../../domain/entities/registro_historial.dart';
import '../models/historial_dto.dart';

abstract interface class HistorialRemoteDataSource {
  Future<PaginaHistorial> obtenerPagina({
    required int pagina,
    required int limite,
    ResultadoIngreso? resultado,
  });
}

final class HistorialRemoteDataSourceImpl implements HistorialRemoteDataSource {
  const HistorialRemoteDataSourceImpl({
    required HttpGateway httpGateway,
    required SessionTokenProvider sessionTokenProvider,
  }) : _httpGateway = httpGateway,
       _sessionTokenProvider = sessionTokenProvider;

  final HttpGateway _httpGateway;
  final SessionTokenProvider _sessionTokenProvider;

  @override
  Future<PaginaHistorial> obtenerPagina({
    required int pagina,
    required int limite,
    ResultadoIngreso? resultado,
  }) async {
    final token = await _sessionTokenProvider.readAccessToken();
    if (token == null) throw const UnauthorizedFailure();

    final consulta = consultaHistorial(
      pagina: pagina,
      limite: limite,
      resultado: resultado,
    );
    final response = await _httpGateway.get(
      '/ingresos/historial?$consulta',
      headers: {'Authorization': 'Bearer $token'},
    );

    final body = response.body;
    if (!response.esExitosa) {
      final error = body?['error'];
      final mensaje = error is Map ? error['mensaje'] as String? : null;
      if (response.statusCode == 401) {
        throw mensaje == null
            ? const UnauthorizedFailure()
            : UnauthorizedFailure(mensaje);
      }
      throw mensaje == null ? const ServerFailure() : ServerFailure(mensaje);
    }
    if (body == null) throw const DataFailure();
    return paginaHistorialFromJson(body);
  }
}
