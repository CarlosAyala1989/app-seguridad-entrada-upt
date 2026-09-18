import 'usuario.dart';

final class SesionEstudiante {
  const SesionEstudiante({
    required this.tipoToken,
    required this.tokenAcceso,
    required this.tokenRenovacion,
    required this.tokenAccesoExpiraEn,
    required this.tokenRenovacionExpiraEn,
    required this.usuario,
  });

  final String tipoToken;
  final String tokenAcceso;
  final String tokenRenovacion;
  final DateTime tokenAccesoExpiraEn;
  final DateTime tokenRenovacionExpiraEn;
  final Usuario usuario;

  /// Verifica si el usuario tiene al menos uno de los roles autorizados por la aplicación.
  bool get tieneRolPermitido {
    const rolesPermitidos = {'ESTUDIANTE', 'DOCENTE', 'TRABAJADOR'};
    return usuario.roles.any(rolesPermitidos.contains);
  }
}