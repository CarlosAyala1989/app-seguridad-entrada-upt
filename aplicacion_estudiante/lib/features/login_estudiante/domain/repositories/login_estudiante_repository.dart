import '../entities/flujo_login.dart';
import '../entities/sesion_estudiante.dart';
import '../entities/usuario.dart';

abstract interface class LoginEstudianteRepository {
  /// Obtiene un nuevo CAPTCHA de la intranet con su imagen y transacción.
  Future<CaptchaIntranet> obtenerCaptcha();

  /// Valida código, contraseña numérica y respuesta del CAPTCHA.
  Future<VerificacionIntranet> verificarIntranet({
    required String transaccionId,
    required String codigo,
    required String contrasena,
    required String captcha,
  });

  /// Inicia el flujo OAuth y devuelve la URL que debe abrirse en el navegador.
  Future<AutorizacionGoogle> iniciarGoogle({
    required String verificacionIntranetId,
  });

  /// Consulta el estado de la transacción OAuth (polling).
  Future<ResultadoEstadoGoogle> consultarEstadoGoogle(String transaccionId);

  /// Renueva la sesión enviando el token de renovación vigente.
  Future<SesionEstudiante> renovarSesion(String tokenRenovacion);

  /// Obtiene el usuario autenticado usando el token de acceso vigente.
  Future<Usuario> consultarSesion(String tokenAcceso);

  /// Invalida la sesión actual en el backend.
  Future<void> cerrarSesion(String tokenAcceso);
}