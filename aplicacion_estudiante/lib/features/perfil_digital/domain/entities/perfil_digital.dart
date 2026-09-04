final class PerfilDigital {
  const PerfilDigital({
    required this.nombreCompleto,
    required this.codigoInstitucional,
    required this.correoInstitucional,
    required this.rol,
    required this.escuela,
    required this.estadoVerificacion,
    required this.estadoAcceso,
    this.fotoUrl,
  });

  final String nombreCompleto;
  final String codigoInstitucional;
  final String correoInstitucional;
  final String rol;
  final String escuela;
  final String estadoVerificacion;
  final String estadoAcceso;
  final String? fotoUrl;
}
