final class Usuario {
  const Usuario({
    required this.id,
    required this.codigoInstitucional,
    required this.correoInstitucional,
    required this.nombres,
    required this.apellidos,
    required this.roles,
  });

  final int id;
  final String codigoInstitucional;
  final String correoInstitucional;
  final String nombres;
  final String apellidos;
  final List<String> roles;
}