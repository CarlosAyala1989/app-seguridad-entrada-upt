import '../../../../core/error/failure.dart';

sealed class LoginFailure extends Failure {
  const LoginFailure(super.message);
}

/// Fallo cuando las credenciales (código, contraseña o captcha) son incorrectas.
final class CredencialesInvalidasFailure extends LoginFailure {
  const CredencialesInvalidasFailure([
    super.message = 'Credenciales de intranet no válidas.',
  ]);
}

/// Fallo cuando el CAPTCHA o la transacción temporal venció.
final class CaptchaExpiradoFailure extends LoginFailure {
  const CaptchaExpiradoFailure([
    super.message = 'El CAPTCHA ha expirado. Solicite uno nuevo.',
  ]);
}

/// Fallo cuando los servidores de la intranet están saturados o no disponibles.
final class IntranetNoDisponibleFailure extends LoginFailure {
  const IntranetNoDisponibleFailure([
    super.message = 'La intranet no se encuentra disponible.',
  ]);
}

/// Fallo cuando el usuario autenticado no cuenta con el rol de ESTUDIANTE, DOCENTE o TRABAJADOR.
final class RolNoAutorizadoFailure extends LoginFailure {
  const RolNoAutorizadoFailure([
    super.message = 'El usuario no cuenta con un rol autorizado.',
  ]);
}

/// Fallo para errores devueltos por Google OAuth o rechazo de dominio.
final class GoogleAuthFailure extends LoginFailure {
  const GoogleAuthFailure([
    super.message = 'Error en la autenticación con Google Workspace.',
  ]);
}

/// Fallo genérico para errores inesperados del backend o respuestas no reconocidas.
final class LoginGenericoFailure extends LoginFailure {
  const LoginGenericoFailure([
    super.message = 'Ocurrió un error inesperado al iniciar sesión.',
  ]);
}
