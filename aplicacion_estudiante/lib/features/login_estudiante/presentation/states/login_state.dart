import '../../domain/entities/flujo_login.dart';
import '../../domain/entities/usuario.dart';

sealed class LoginState {
  const LoginState();
}

/// Estado inicial previo al primer intento de carga.
final class LoginInitialState extends LoginState {
  const LoginInitialState();
}

/// Carga en progreso del CAPTCHA institucional.
final class LoginCargandoCaptchaState extends LoginState {
  const LoginCargandoCaptchaState();
}

/// CAPTCHA disponible y listo para responder en la interfaz.
final class LoginCaptchaListoState extends LoginState {
  const LoginCaptchaListoState(this.captcha);

  final CaptchaIntranet captcha;
}

/// Validación de credenciales de intranet y CAPTCHA en proceso.
final class LoginVerificandoIntranetState extends LoginState {
  const LoginVerificandoIntranetState();
}

/// Transacción de Google Workspace abierta en el navegador; polling activo.
final class LoginEsperandoGoogleState extends LoginState {
  const LoginEsperandoGoogleState({
    required this.transaccionId,
    required this.urlAutorizacion,
    this.mensajeInformativo = 'Esperando confirmación en Google Workspace...',
  });

  final String transaccionId;
  final Uri urlAutorizacion;
  final String mensajeInformativo;
}

/// Sesión adoptada satisfactoriamente con roles autorizados.
final class LoginExitosoState extends LoginState {
  const LoginExitosoState(this.usuario);

  final Usuario usuario;
}

/// Ocurrió un error en cualquiera de los pasos del flujo.
final class LoginErrorState extends LoginState {
  const LoginErrorState({
    required this.mensaje,
    this.puedeReintentarCaptcha = true,
  });

  final String mensaje;
  final bool puedeReintentarCaptcha;
}
