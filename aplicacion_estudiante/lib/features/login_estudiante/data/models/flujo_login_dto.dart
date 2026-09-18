import 'sesion_estudiante_dto.dart';

final class CaptchaIntranetDto {
  const CaptchaIntranetDto({
    required this.transaccionId,
    required this.imagenBase64,
    required this.tipoImagen,
    required this.expiraEn,
  });

  factory CaptchaIntranetDto.fromJson(Map<String, Object?> json) {
    return CaptchaIntranetDto(
      transaccionId: json['transaccion_id']! as String,
      imagenBase64: json['imagen_base64']! as String,
      tipoImagen: json['tipo_imagen']! as String,
      expiraEn: json['expira_en']! as String,
    );
  }

  final String transaccionId;
  final String imagenBase64;
  final String tipoImagen;
  final String expiraEn;
}

final class VerificacionIntranetDto {
  const VerificacionIntranetDto({
    required this.codigo,
    required this.nombreApellidos,
    required this.verificacionIntranetId,
    required this.verificacionExpiraEn,
  });

  factory VerificacionIntranetDto.fromJson(Map<String, Object?> json) {
    return VerificacionIntranetDto(
      codigo: json['codigo']! as String,
      nombreApellidos: json['nombre_apellidos']! as String,
      verificacionIntranetId: json['verificacion_intranet_id']! as String,
      verificacionExpiraEn: json['verificacion_expira_en']! as String,
    );
  }

  final String codigo;
  final String nombreApellidos;
  final String verificacionIntranetId;
  final String expiraEn = '';
  final String verificacionExpiraEn;
}

final class AutorizacionGoogleDto {
  const AutorizacionGoogleDto({
    required this.transaccionId,
    required this.urlAutorizacion,
    required this.expiraEn,
  });

  factory AutorizacionGoogleDto.fromJson(Map<String, Object?> json) {
    return AutorizacionGoogleDto(
      transaccionId: json['transaccion_id']! as String,
      urlAutorizacion: json['url_autorizacion']! as String,
      expiraEn: json['expira_en']! as String,
    );
  }

  final String transaccionId;
  final String urlAutorizacion;
  final String expiraEn;
}

final class EstadoGoogleDto {
  const EstadoGoogleDto({
    required this.estado,
    this.sesion,
    this.errorCodigo,
    this.errorMensaje,
  });

  factory EstadoGoogleDto.fromJson(Map<String, Object?> json) {
    final estado = json['estado']! as String;
    SesionEstudianteDto? sesion;
    if (json['sesion'] != null) {
      sesion = SesionEstudianteDto.fromJson(
        json['sesion']! as Map<String, Object?>,
      );
    }

    String? errorCodigo;
    String? errorMensaje;
    if (json['error'] != null) {
      final error = json['error']! as Map<String, Object?>;
      errorCodigo = error['codigo'] as String?;
      errorMensaje = error['mensaje'] as String?;
    }

    return EstadoGoogleDto(
      estado: estado,
      sesion: sesion,
      errorCodigo: errorCodigo,
      errorMensaje: errorMensaje,
    );
  }

  final String estado;
  final SesionEstudianteDto? sesion;
  final String? errorCodigo;
  final String? errorMensaje;
}
