import '../../../../core/error/failure.dart';

final class PerfilDigitalDto {
  const PerfilDigitalDto({
    required this.fullName,
    required this.institutionalCode,
    required this.institutionalEmail,
    required this.role,
    required this.school,
    required this.verificationStatus,
    required this.accessStatus,
    this.photoUrl,
  });

  /// Lee la respuesta de `GET /identidad-digital` (campo `datos`).
  factory PerfilDigitalDto.fromJson(Map<String, Object?> json) {
    String requiredString(Object? value, String key) {
      if (value is! String || value.trim().isEmpty) {
        throw DataFailure('El campo "$key" no es válido.');
      }
      return value;
    }

    Map<String, Object?> requiredMap(String key) {
      final value = json[key];
      if (value is! Map) {
        throw DataFailure('El campo "$key" no es válido.');
      }
      return value.cast<String, Object?>();
    }

    final roles = json['roles'];
    if (roles is! List || roles.isEmpty || roles.first is! String) {
      throw const DataFailure('El campo "roles" no es válido.');
    }

    final photo = json['foto_url'];
    if (photo != null && photo is! String) {
      throw const DataFailure('El campo "foto_url" no es válido.');
    }

    final verificacion = requiredMap('verificacion');
    final acceso = requiredMap('acceso');
    final perfilAcademico = json['perfil_academico'];
    final escuela = perfilAcademico is Map ? perfilAcademico['escuela'] : null;

    return PerfilDigitalDto(
      fullName: requiredString(json['nombre_completo'], 'nombre_completo'),
      institutionalCode: requiredString(
        json['codigo_institucional'],
        'codigo_institucional',
      ),
      institutionalEmail: requiredString(
        json['correo_institucional'],
        'correo_institucional',
      ),
      role: roles.first as String,
      // Docentes y trabajadores no tienen perfil académico.
      school: escuela is String && escuela.trim().isNotEmpty
          ? escuela
          : 'No registrada',
      verificationStatus: requiredString(
        verificacion['estado'],
        'verificacion.estado',
      ),
      accessStatus: requiredString(
        acceso['estado_autorizacion'],
        'acceso.estado_autorizacion',
      ),
      photoUrl: photo as String?,
    );
  }

  final String fullName;
  final String institutionalCode;
  final String institutionalEmail;
  final String role;
  final String school;
  final String verificationStatus;
  final String accessStatus;
  final String? photoUrl;
}
