import '../../../../core/auth/session_token_provider.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/http_gateway.dart';
import '../../domain/entities/notificacion.dart';
import '../models/notificacion_dto.dart';

final class NotificacionesRemoteDataSource {
  const NotificacionesRemoteDataSource({
    required HttpGateway httpGateway,
    required SessionTokenProvider sessionTokenProvider,
  }) : _httpGateway = httpGateway,
       _sessionTokenProvider = sessionTokenProvider;

  final HttpGateway _httpGateway;
  final SessionTokenProvider _sessionTokenProvider;

  Future<PaginaNotificaciones> listar({
    required int pagina,
    required int limite,
    TipoNotificacion? tipo,
    bool soloNoLeidas = false,
  }) async {
    final consulta = consultaNotificaciones(
      pagina: pagina,
      limite: limite,
      tipo: tipo,
      soloNoLeidas: soloNoLeidas,
    );
    final response = await _httpGateway.get(
      '/notificaciones?$consulta',
      headers: await _autorizacion(),
    );
    return paginaNotificacionesFromJson(_cuerpo(response));
  }

  Future<ResumenNotificaciones> resumen() async {
    final response = await _httpGateway.get(
      '/notificaciones/resumen',
      headers: await _autorizacion(),
    );
    return resumenFromJson(_cuerpo(response));
  }

  Future<Notificacion> detalle(int id) async {
    final response = await _httpGateway.get(
      '/notificaciones/$id',
      headers: await _autorizacion(),
    );
    return notificacionFromJson(_cuerpo(response)['datos']);
  }

  Future<Notificacion> marcarLeida(int id) async {
    // Sin cuerpo, como permite la API.
    final response = await _httpGateway.patch(
      '/notificaciones/$id/leida',
      headers: await _autorizacion(),
    );
    return notificacionFromJson(_cuerpo(response)['datos']);
  }

  Future<Map<String, String>> _autorizacion() async {
    final token = await _sessionTokenProvider.readAccessToken();
    if (token == null) throw const UnauthorizedFailure();
    return {'Authorization': 'Bearer $token'};
  }

  /// Devuelve el JSON o lanza un `Failure` con el mensaje de la API.
  Map<String, Object?> _cuerpo(HttpResponseData response) {
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
    return body;
  }
}
