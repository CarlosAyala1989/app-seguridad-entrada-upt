import 'package:aplicacion_estudiante/core/auth/secure_session_storage.dart';
import 'package:aplicacion_estudiante/core/error/failure.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/data/datasources/login_estudiante_remote_data_source.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/data/models/flujo_login_dto.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/data/models/sesion_estudiante_dto.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/data/repositories/login_estudiante_repository_impl.dart';
import 'package:aplicacion_estudiante/features/login_estudiante/domain/failures/login_failure.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fuente remota que falla al consultar el estado de Google con [error].
final class _RemotoQueFalla implements LoginEstudianteRemoteDataSource {
  _RemotoQueFalla(this.error);

  final Failure error;

  @override
  Future<EstadoGoogleDto> consultarEstadoGoogle(String transaccionId) async =>
      throw error;

  @override
  Future<CaptchaIntranetDto> obtenerCaptcha() => throw UnimplementedError();

  @override
  Future<VerificacionIntranetDto> verificarIntranet({
    required String transaccionId,
    required String codigo,
    required String contrasena,
    required String captcha,
  }) => throw UnimplementedError();

  @override
  Future<AutorizacionGoogleDto> iniciarGoogle({
    required String verificacionIntranetId,
  }) => throw UnimplementedError();

  @override
  Future<SesionEstudianteDto> renovarSesion(String tokenRenovacion) =>
      throw UnimplementedError();

  @override
  Future<UsuarioDto> consultarSesion(String tokenAcceso) =>
      throw UnimplementedError();

  @override
  Future<void> cerrarSesion(String tokenAcceso) => throw UnimplementedError();
}

void main() {
  group('consultarEstadoGoogle', () {
    test('deja pasar el NetworkFailure para que el ViewModel reintente', () {
      final repositorio = LoginEstudianteRepositoryImpl(
        remoteDataSource: _RemotoQueFalla(const NetworkFailure()),
        sessionStorage: const SecureSessionStorage(),
      );

      expect(
        repositorio.consultarEstadoGoogle('google-trans-id'),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('convierte los demás fallos en GoogleAuthFailure', () {
      final repositorio = LoginEstudianteRepositoryImpl(
        remoteDataSource: _RemotoQueFalla(const ServerFailure('Sin sesión.')),
        sessionStorage: const SecureSessionStorage(),
      );

      expect(
        repositorio.consultarEstadoGoogle('google-trans-id'),
        throwsA(
          isA<GoogleAuthFailure>().having(
            (f) => f.message,
            'message',
            'Sin sesión.',
          ),
        ),
      );
    });
  });
}
