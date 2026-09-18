import '../../domain/entities/flujo_login.dart';
import '../../domain/entities/sesion_estudiante.dart';
import '../../domain/entities/usuario.dart';
import '../models/flujo_login_dto.dart';
import '../models/sesion_estudiante_dto.dart';

extension UsuarioDtoMapper on UsuarioDto {
  Usuario toDomain() {
    return Usuario(
      id: id,
      codigoInstitucional: codigoInstitucional,
      correoInstitucional: correoInstitucional,
      nombres: nombres,
      apellidos: apellidos,
      roles: roles,
    );
  }
}

extension SesionEstudianteDtoMapper on SesionEstudianteDto {
  SesionEstudiante toDomain() {
    return SesionEstudiante(
      tipoToken: tipoToken,
      tokenAcceso: tokenAcceso,
      tokenRenovacion: tokenRenovacion,
      tokenAccesoExpiraEn: DateTime.parse(tokenAccesoExpiraEn),
      tokenRenovacionExpiraEn: DateTime.parse(tokenRenovacionExpiraEn),
      usuario: usuario.toDomain(),
    );
  }
}

extension CaptchaIntranetDtoMapper on CaptchaIntranetDto {
  CaptchaIntranet toDomain() {
    return CaptchaIntranet(
      transaccionId: transaccionId,
      imagenBase64: imagenBase64,
      tipoImagen: tipoImagen,
      expiraEn: DateTime.parse(expiraEn),
    );
  }
}

extension VerificacionIntranetDtoMapper on VerificacionIntranetDto {
  VerificacionIntranet toDomain() {
    return VerificacionIntranet(
      codigo: codigo,
      nombreApellidos: nombreApellidos,
      verificacionIntranetId: verificacionIntranetId,
      verificacionExpiraEn: DateTime.parse(verificacionExpiraEn),
    );
  }
}

extension AutorizacionGoogleDtoMapper on AutorizacionGoogleDto {
  AutorizacionGoogle toDomain() {
    return AutorizacionGoogle(
      transaccionId: transaccionId,
      urlAutorizacion: Uri.parse(urlAutorizacion),
      expiraEn: DateTime.parse(expiraEn),
    );
  }
}

extension EstadoGoogleDtoMapper on EstadoGoogleDto {
  ResultadoEstadoGoogle toDomain() {
    final estadoEnum = switch (estado.toUpperCase()) {
      'PENDIENTE' => EstadoGoogle.pendiente,
      'PROCESANDO' => EstadoGoogle.procesando,
      'COMPLETA' => EstadoGoogle.completa,
      'ERROR' => EstadoGoogle.error,
      _ => throw FormatException('Estado de Google no reconocido: $estado'),
    };

    return ResultadoEstadoGoogle(
      estado: estadoEnum,
      sesion: sesion?.toDomain(),
      errorCodigo: errorCodigo,
      errorMensaje: errorMensaje,
    );
  }
}
