import '../../../../core/auth/secure_session_storage.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/flujo_login.dart';
import '../../domain/entities/sesion_estudiante.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/failures/login_failure.dart';
import '../../domain/repositories/login_estudiante_repository.dart';
import '../datasources/login_estudiante_remote_data_source.dart';
import '../mappers/login_mappers.dart';

final class LoginEstudianteRepositoryImpl implements LoginEstudianteRepository {
  const LoginEstudianteRepositoryImpl({
    required LoginEstudianteRemoteDataSource remoteDataSource,
    required SecureSessionStorage sessionStorage,
  }) : _remoteDataSource = remoteDataSource,
       _sessionStorage = sessionStorage;

  final LoginEstudianteRemoteDataSource _remoteDataSource;
  final SecureSessionStorage _sessionStorage;

   @override
  Future<CaptchaIntranet> obtenerCaptcha() async {
    try {
      final dto = await _remoteDataSource.obtenerCaptcha();
      return dto.toDomain();
    } on NetworkFailure catch (e) {
      // ignore: avoid_print
      print('DEBUG CAPTCHA (NetworkFailure): ${e.message}');
      throw IntranetNoDisponibleFailure(e.message);
    } on Failure catch (e) {
      // ignore: avoid_print
      print('DEBUG CAPTCHA (Failure): ${e.message}');
      throw LoginGenericoFailure(e.message);
    } catch (e, st) {
      // ignore: avoid_print
      print('DEBUG CAPTCHA (otro): $e\n$st');
      throw const LoginGenericoFailure();
    }
  }

  @override
  Future<VerificacionIntranet> verificarIntranet({
    required String transaccionId,
    required String codigo,
    required String contrasena,
    required String captcha,
  }) async {
    try {
      final dto = await _remoteDataSource.verificarIntranet(
        transaccionId: transaccionId,
        codigo: codigo,
        contrasena: contrasena,
        captcha: captcha,
      );
      return dto.toDomain();
    } on UnauthorizedFailure catch (e) {
      throw CredencialesInvalidasFailure(e.message);
    } on NetworkFailure catch (e) {
      throw IntranetNoDisponibleFailure(e.message);
    } on Failure catch (e) {
      throw LoginGenericoFailure(e.message);
    } catch (_) {
      throw const LoginGenericoFailure();
    }
  }

  @override
  Future<AutorizacionGoogle> iniciarGoogle({
    required String verificacionIntranetId,
  }) async {
    try {
      final dto = await _remoteDataSource.iniciarGoogle(
        verificacionIntranetId: verificacionIntranetId,
      );
      return dto.toDomain();
    } on Failure catch (e) {
      throw GoogleAuthFailure(e.message);
    } catch (_) {
      throw const GoogleAuthFailure();
    }
  }

  @override
  Future<ResultadoEstadoGoogle> consultarEstadoGoogle(
    String transaccionId,
  ) async {
    try {
      final dto = await _remoteDataSource.consultarEstadoGoogle(transaccionId);
      final resultado = dto.toDomain();

      if (resultado.estado == EstadoGoogle.completa &&
          resultado.sesion != null) {
        final sesion = resultado.sesion!;
        if (!sesion.tieneRolPermitido) {
          throw const RolNoAutorizadoFailure();
        }

        await _sessionStorage.guardarTokens(
          tokenAcceso: sesion.tokenAcceso,
          tokenRenovacion: sesion.tokenRenovacion,
          tokenAccesoExpiraEn: sesion.tokenAccesoExpiraEn,
          tokenRenovacionExpiraEn: sesion.tokenRenovacionExpiraEn,
        );
      }

      return resultado;
    } on LoginFailure {
      rethrow;
    } on Failure catch (e) {
      throw GoogleAuthFailure(e.message);
    } catch (_) {
      throw const GoogleAuthFailure();
    }
  }

  @override
  Future<SesionEstudiante> renovarSesion(String tokenRenovacion) async {
    try {
      final dto = await _remoteDataSource.renovarSesion(tokenRenovacion);
      final sesion = dto.toDomain();

      if (!sesion.tieneRolPermitido) {
        await _sessionStorage.limpiar();
        throw const RolNoAutorizadoFailure();
      }

      await _sessionStorage.guardarTokens(
        tokenAcceso: sesion.tokenAcceso,
        tokenRenovacion: sesion.tokenRenovacion,
        tokenAccesoExpiraEn: sesion.tokenAccesoExpiraEn,
        tokenRenovacionExpiraEn: sesion.tokenRenovacionExpiraEn,
      );

      return sesion;
    } on LoginFailure {
      rethrow;
    } on UnauthorizedFailure catch (e) {
      await _sessionStorage.limpiar();
      throw CredencialesInvalidasFailure(e.message);
    } on Failure catch (e) {
      throw LoginGenericoFailure(e.message);
    } catch (_) {
      throw const LoginGenericoFailure();
    }
  }

  @override
  Future<Usuario> consultarSesion(String tokenAcceso) async {
    try {
      final dto = await _remoteDataSource.consultarSesion(tokenAcceso);
      return dto.toDomain();
    } on UnauthorizedFailure catch (e) {
      await _sessionStorage.limpiar();
      throw CredencialesInvalidasFailure(e.message);
    } on Failure catch (e) {
      throw LoginGenericoFailure(e.message);
    } catch (_) {
      throw const LoginGenericoFailure();
    }
  }

  @override
  Future<void> cerrarSesion(String tokenAcceso) async {
    try {
      await _remoteDataSource.cerrarSesion(tokenAcceso);
    } catch (_) {
      // Ignora caídas de red para garantizar la limpieza local
    } finally {
      await _sessionStorage.limpiar();
    }
  }
}
