import '../../../../core/error/failure.dart';
import '../../../../core/network/http_gateway.dart';
import '../models/flujo_login_dto.dart';
import '../models/sesion_estudiante_dto.dart';

abstract interface class LoginEstudianteRemoteDataSource {
  Future<CaptchaIntranetDto> obtenerCaptcha();

  Future<VerificacionIntranetDto> verificarIntranet({
    required String transaccionId,
    required String codigo,
    required String contrasena,
    required String captcha,
  });

  Future<AutorizacionGoogleDto> iniciarGoogle({
    required String verificacionIntranetId,
  });

  Future<EstadoGoogleDto> consultarEstadoGoogle(String transaccionId);

  Future<SesionEstudianteDto> renovarSesion(String tokenRenovacion);

  Future<UsuarioDto> consultarSesion(String tokenAcceso);

  Future<void> cerrarSesion(String tokenAcceso);
}

final class LoginEstudianteRemoteDataSourceImpl
    implements LoginEstudianteRemoteDataSource {
  const LoginEstudianteRemoteDataSourceImpl({required HttpGateway httpGateway})
    : _httpGateway = httpGateway;

  final HttpGateway _httpGateway;

  @override
  Future<CaptchaIntranetDto> obtenerCaptcha() async {
    final response = await _httpGateway
        .get('/registro-estudiante/intranet/captcha')
        .timeout(const Duration(seconds: 45));
    final datos = _extraerDatos(response);
    return CaptchaIntranetDto.fromJson(datos);
  }

  @override
  Future<VerificacionIntranetDto> verificarIntranet({
    required String transaccionId,
    required String codigo,
    required String contrasena,
    required String captcha,
  }) async {
    final response = await _httpGateway
        .post(
          '/registro-estudiante/intranet/verificar',
          body: {
            'transaccion_id': transaccionId,
            'codigo': codigo,
            'contrasena': contrasena,
            'captcha': captcha,
          },
        )
        .timeout(const Duration(seconds: 120));
    final datos = _extraerDatos(response);
    return VerificacionIntranetDto.fromJson(datos);
  }

  @override
  Future<AutorizacionGoogleDto> iniciarGoogle({
    required String verificacionIntranetId,
  }) async {
    final response = await _httpGateway
        .post(
          '/registro-estudiante/google/iniciar',
          body: {'verificacion_intranet_id': verificacionIntranetId},
        )
        .timeout(const Duration(seconds: 15));
    final datos = _extraerDatos(response);
    return AutorizacionGoogleDto.fromJson(datos);
  }

  @override
  Future<EstadoGoogleDto> consultarEstadoGoogle(String transaccionId) async {
    final response = await _httpGateway
        .get('/registro-estudiante/google/estado/$transaccionId')
        .timeout(const Duration(seconds: 15));
    final datos = _extraerDatos(response);
    return EstadoGoogleDto.fromJson(datos);
  }

  @override
  Future<SesionEstudianteDto> renovarSesion(String tokenRenovacion) async {
    final response = await _httpGateway
        .post(
          '/autenticacion/renovar-sesion',
          body: {'token_renovacion': tokenRenovacion},
        )
        .timeout(const Duration(seconds: 15));
    final datos = _extraerDatos(response);
    return SesionEstudianteDto.fromJson(datos);
  }

  @override
  Future<UsuarioDto> consultarSesion(String tokenAcceso) async {
    final response = await _httpGateway.get(
      '/autenticacion/sesion',
      headers: {'Authorization': 'Bearer $tokenAcceso'},
    );
    final datos = _extraerDatos(response);
    final usuarioJson = datos['usuario'];
    if (usuarioJson is! Map<String, Object?>) {
      throw const DataFailure();
    }
    return UsuarioDto.fromJson(usuarioJson);
  }

  @override
  Future<void> cerrarSesion(String tokenAcceso) async {
    await _httpGateway.post(
      '/autenticacion/cerrar-sesion',
      headers: {'Authorization': 'Bearer $tokenAcceso'},
    );
  }

  Map<String, Object?> _extraerDatos(HttpResponseData response) {
    final body = response.body;
    if (body == null) {
      throw const DataFailure();
    }
    final datos = body['datos'];
    if (datos is! Map<String, Object?>) {
      throw const DataFailure();
    }
    return datos;
  }
}
