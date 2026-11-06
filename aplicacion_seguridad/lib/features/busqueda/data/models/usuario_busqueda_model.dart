class UsuarioBusquedaModel {
  final int? id;
  final String codigoInstitucional;
  final String nombreCompleto;
  final String? correoInstitucional;
  final String? fotoUrl;
  final String? escuela;
  final String estadoAcceso; // 'HABILITADO' | 'ACTIVO' | 'BLOQUEADO' | 'INACTIVO'
  final String? estadoAutorizacion;
  final bool identidadVerificada;
  final bool bloqueoVigente;
  final bool permiteIngreso; // Siempre false según contrato Issue #14
  final List<String> roles;

  const UsuarioBusquedaModel({
    this.id,
    required this.codigoInstitucional,
    required this.nombreCompleto,
    this.correoInstitucional,
    this.fotoUrl,
    this.escuela,
    required this.estadoAcceso,
    this.estadoAutorizacion,
    this.identidadVerificada = false,
    this.bloqueoVigente = false,
    this.permiteIngreso = false,
    this.roles = const ['ESTUDIANTE'],
  });

  bool get esHabilitado =>
      (estadoAcceso.toUpperCase() == 'HABILITADO' ||
          estadoAcceso.toUpperCase() == 'ACTIVO') &&
      !bloqueoVigente;

  factory UsuarioBusquedaModel.fromJson(Map<String, dynamic> json) {
    final datos = json['datos'] as Map<String, dynamic>? ?? json;

    final estadoRaw = datos['estado_acceso'] as String? ??
        datos['estado'] as String? ??
        (datos['estado_autorizacion'] == 'AUTORIZADO' ? 'HABILITADO' : 'INACTIVO');

    final rolesRaw = (datos['roles'] as List<dynamic>? ??
            datos['tipos_usuario'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ??
        const ['ESTUDIANTE'];

    return UsuarioBusquedaModel(
      id: datos['id'] as int?,
      codigoInstitucional: datos['codigo_institucional'] as String? ??
          datos['codigo'] as String? ??
          '',
      nombreCompleto: datos['nombre_completo'] as String? ?? 'Usuario UPT',
      correoInstitucional: datos['correo_institucional'] as String? ??
          datos['correo'] as String?,
      fotoUrl: datos['foto_url'] as String?,
      escuela: datos['escuela'] as String?,
      estadoAcceso: estadoRaw,
      estadoAutorizacion: datos['estado_autorizacion'] as String?,
      identidadVerificada: (datos['identidad_verificada'] as bool?) ?? false,
      bloqueoVigente: (datos['bloqueo_vigente'] as bool?) ?? false,
      permiteIngreso: (datos['permite_ingreso'] as bool?) ?? false,
      roles: rolesRaw,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'codigo_institucional': codigoInstitucional,
        'nombre_completo': nombreCompleto,
        if (correoInstitucional != null)
          'correo_institucional': correoInstitucional,
        if (fotoUrl != null) 'foto_url': fotoUrl,
        if (escuela != null) 'escuela': escuela,
        'estado_acceso': estadoAcceso,
        if (estadoAutorizacion != null)
          'estado_autorizacion': estadoAutorizacion,
        'identidad_verificada': identidadVerificada,
        'bloqueo_vigente': bloqueoVigente,
        'permite_ingreso': permiteIngreso,
        'roles': roles,
      };
}
