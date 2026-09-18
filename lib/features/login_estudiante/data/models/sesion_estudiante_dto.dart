final class UsuarioDto {
  const UsuarioDto({
    required this.id,
    required this.codigoInstitucional,
    required this.correoInstitucional,
    required this.nombres,
    required this.apellidos,
    required this.roles,
  });

  factory UsuarioDto.fromJson(Map<String, Object?> json) {
    return UsuarioDto(
      id: json['id']! as int,
      codigoInstitucional: json['codigo_institucional']! as String,
      correoInstitucional: json['correo_institucional']! as String,
      nombres: json['nombres']! as String,
      apellidos: json['apellidos']! as String,
      roles: (json['roles']! as List<Object?>).cast<String>(),
    );
  }

  final int id;
  final String codigoInstitucional;
  final String correoInstitucional;
  final String nombres;
  final String apellidos;
  final List<String> roles;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'codigo_institucional': codigoInstitucional,
      'correo_institucional': correoInstitucional,
      'nombres': nombres,
      'apellidos': apellidos,
      'roles': roles,
    };
  }
}

final class SesionEstudianteDto {
  const SesionEstudianteDto({
    required this.tipoToken,
    required this.tokenAcceso,
    required this.tokenRenovacion,
    required this.tokenAccesoExpiraEn,
    required this.tokenRenovacionExpiraEn,
    required this.usuario,
  });

  factory SesionEstudianteDto.fromJson(Map<String, Object?> json) {
    return SesionEstudianteDto(
      tipoToken: json['tipo_token']! as String,
      tokenAcceso: json['token_acceso']! as String,
      tokenRenovacion: json['token_renovacion']! as String,
      tokenAccesoExpiraEn: json['token_acceso_expira_en']! as String,
      tokenRenovacionExpiraEn: json['token_renovacion_expira_en']! as String,
      usuario: UsuarioDto.fromJson(json['usuario']! as Map<String, Object?>),
    );
  }

  final String tipoToken;
  final String tokenAcceso;
  final String tokenRenovacion;
  final String tokenAccesoExpiraEn;
  final String tokenRenovacionExpiraEn;
  final UsuarioDto usuario;

  Map<String, Object?> toJson() {
    return {
      'tipo_token': tipoToken,
      'token_acceso': tokenAcceso,
      'token_renovacion': tokenRenovacion,
      'token_acceso_expira_en': tokenAccesoExpiraEn,
      'token_renovacion_expira_en': tokenRenovacionExpiraEn,
      'usuario': usuario.toJson(),
    };
  }
}
