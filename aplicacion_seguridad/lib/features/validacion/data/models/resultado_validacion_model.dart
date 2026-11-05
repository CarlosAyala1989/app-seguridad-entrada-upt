class IdentidadEstudianteModel {
  final String nombreCompleto;
  final String codigoInstitucional;
  final String? escuela;
  final String? estadoAcademico;
  final String? fotoUrl;
  final List<String> tiposUsuario;

  const IdentidadEstudianteModel({
    required this.nombreCompleto,
    required this.codigoInstitucional,
    this.escuela,
    this.estadoAcademico,
    this.fotoUrl,
    this.tiposUsuario = const ['ESTUDIANTE'],
  });

  factory IdentidadEstudianteModel.fromJson(Map<String, dynamic> json) {
    return IdentidadEstudianteModel(
      nombreCompleto: json['nombre_completo'] as String? ?? 'Estudiante UPT',
      codigoInstitucional: json['codigo_institucional'] as String? ??
          json['codigo'] as String? ??
          '',
      escuela: json['escuela'] as String?,
      estadoAcademico: json['estado_academico'] as String?,
      fotoUrl: json['foto_url'] as String?,
      tiposUsuario: (json['tipo_usuario'] as List<dynamic>? ??
              json['roles'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          const ['ESTUDIANTE'],
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre_completo': nombreCompleto,
        'codigo_institucional': codigoInstitucional,
        if (escuela != null) 'escuela': escuela,
        if (estadoAcademico != null) 'estado_academico': estadoAcademico,
        if (fotoUrl != null) 'foto_url': fotoUrl,
        'tipo_usuario': tiposUsuario,
      };
}

class ResultadoValidacionModel {
  final int? registroId; // ID del registro persistido de la decisión
  final int? turnoId; // ID del turno operativo asociado
  final bool puedeConfirmar; // Indicador explícito de autorización confirmable
  final String resultado; // 'AUTORIZADO' | 'DENEGADO'
  final String motivo; // Código de negocio estable
  final String mensaje; // Mensaje descriptivo
  final String? accionSugerida; // Orientación operativa ante la decisión
  final DateTime registradoEn;
  final String puntoAccesoCodigo;
  final String puntoAccesoNombre;
  final IdentidadEstudianteModel? identidad;

  const ResultadoValidacionModel({
    this.registroId,
    this.turnoId,
    this.puedeConfirmar = false,
    required this.resultado,
    required this.motivo,
    required this.mensaje,
    this.accionSugerida,
    required this.registradoEn,
    required this.puntoAccesoCodigo,
    required this.puntoAccesoNombre,
    this.identidad,
  });

  bool get esAutorizado => resultado.toUpperCase() == 'AUTORIZADO';

  /// Condición defensiva oficial (Issue #9):
  /// Solo puede confirmarse el paso si el resultado es AUTORIZADO, puede_confirmar es true,
  /// y la identidad cuenta con nombre, código y al menos un tipo de usuario.
  bool get puedeConfirmarAcceso =>
      esAutorizado &&
      puedeConfirmar == true &&
      identidad != null &&
      identidad!.nombreCompleto.trim().isNotEmpty &&
      identidad!.codigoInstitucional.trim().isNotEmpty &&
      identidad!.tiposUsuario.isNotEmpty;

  factory ResultadoValidacionModel.fromJson(Map<String, dynamic> json) {
    final datos = json['datos'] as Map<String, dynamic>? ?? json;
    final punto = datos['punto_acceso'] as Map<String, dynamic>? ?? {};
    final idMap = datos['identidad'] as Map<String, dynamic>?;

    final resultadoStr = datos['resultado'] as String? ?? 'DENEGADO';
    final esAut = resultadoStr.toUpperCase() == 'AUTORIZADO';

    return ResultadoValidacionModel(
      registroId: datos['registro_id'] as int?,
      turnoId: datos['turno_id'] as int?,
      puedeConfirmar: (datos['puede_confirmar'] as bool?) ?? esAut,
      resultado: resultadoStr,
      motivo: datos['motivo'] as String? ?? 'SIN_MOTIVO',
      mensaje: datos['mensaje'] as String? ?? 'Validación procesada.',
      accionSugerida: datos['accion_sugerida'] as String?,
      registradoEn: datos['registrado_en'] != null
          ? DateTime.tryParse(datos['registrado_en'] as String) ?? DateTime.now()
          : DateTime.now(),
      puntoAccesoCodigo: punto['codigo'] as String? ?? 'PUERTA-01',
      puntoAccesoNombre: punto['nombre'] as String? ?? 'Puerta Principal',
      identidad: idMap != null ? IdentidadEstudianteModel.fromJson(idMap) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (registroId != null) 'registro_id': registroId,
        if (turnoId != null) 'turno_id': turnoId,
        'puede_confirmar': puedeConfirmar,
        'resultado': resultado,
        'motivo': motivo,
        'mensaje': mensaje,
        if (accionSugerida != null) 'accion_sugerida': accionSugerida,
        'registrado_en': registradoEn.toIso8601String(),
        'punto_acceso': {
          'codigo': puntoAccesoCodigo,
          'nombre': puntoAccesoNombre,
        },
        if (identidad != null) 'identidad': identidad!.toJson(),
      };
}
