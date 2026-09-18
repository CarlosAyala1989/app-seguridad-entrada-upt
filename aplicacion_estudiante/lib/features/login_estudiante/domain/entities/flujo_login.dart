import 'sesion_estudiante.dart';

/// Datos del CAPTCHA entregados por la intranet.
final class CaptchaIntranet {
  const CaptchaIntranet({
    required this.transaccionId,
    required this.imagenBase64,
    required this.tipoImagen,
    required this.expiraEn,
  });

  final String transaccionId;
  final String imagenBase64;
  final String tipoImagen;
  final DateTime expiraEn;
}

/// Resultado de la verificación exitosa de credenciales institucionales.
final class VerificacionIntranet {
  const VerificacionIntranet({
    required this.codigo,
    required this.nombreApellidos,
    required this.verificacionIntranetId,
    required this.verificacionExpiraEn,
  });

  final String codigo;
  final String nombreApellidos;
  final String verificacionIntranetId;
  final DateTime verificacionExpiraEn;
}

/// Datos devueltos al iniciar el proceso OAuth con Google Workspace.
final class AutorizacionGoogle {
  const AutorizacionGoogle({
    required this.transaccionId,
    required this.urlAutorizacion,
    required this.expiraEn,
  });

  final String transaccionId;
  final Uri urlAutorizacion;
  final DateTime expiraEn;
}

/// Estados posibles al consultar el resultado de la autorización con Google.
enum EstadoGoogle { pendiente, procesando, completa, error }

/// Resultado del polling del estado de Google.
final class ResultadoEstadoGoogle {
  const ResultadoEstadoGoogle({
    required this.estado,
    this.sesion,
    this.errorCodigo,
    this.errorMensaje,
  });

  final EstadoGoogle estado;
  final SesionEstudiante? sesion;
  final String? errorCodigo;
  final String? errorMensaje;
}
