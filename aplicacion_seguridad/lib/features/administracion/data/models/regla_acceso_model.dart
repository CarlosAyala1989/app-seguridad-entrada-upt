class ReglaAccesoModel {
  final int id;
  final String nombre;
  final String rol; // 'ESTUDIANTE' | 'DOCENTE' | 'TRABAJADOR'
  final String estadoUsuario; // 'ACTIVO' | 'PENDIENTE' | 'BLOQUEADO' | 'INACTIVO' | 'RECHAZADO'
  final String accion; // 'PERMITIR' | 'DENEGAR'
  final int? puntoAccesoId;
  final List<int> diasSemana; // 1 (Lunes) a 7 (Domingo)
  final String horaInicio; // 'HH:mm'
  final String horaFin; // 'HH:mm'
  final DateTime? vigenteDesde;
  final DateTime? vigenteHasta;
  final bool activo;
  final int? creadoPor;
  final int? actualizadoPor;

  const ReglaAccesoModel({
    required this.id,
    required this.nombre,
    required this.rol,
    required this.estadoUsuario,
    required this.accion,
    this.puntoAccesoId,
    required this.diasSemana,
    required this.horaInicio,
    required this.horaFin,
    this.vigenteDesde,
    this.vigenteHasta,
    this.activo = true,
    this.creadoPor,
    this.actualizadoPor,
  });

  bool get esPermitir => accion.toUpperCase() == 'PERMITIR';

  factory ReglaAccesoModel.fromJson(Map<String, dynamic> json) {
    final datos = json['datos'] as Map<String, dynamic>? ?? json;

    return ReglaAccesoModel(
      id: datos['id'] as int? ?? 0,
      nombre: datos['nombre'] as String? ?? 'Regla de acceso',
      rol: datos['rol'] as String? ?? 'ESTUDIANTE',
      estadoUsuario: datos['estado_usuario'] as String? ?? 'ACTIVO',
      accion: datos['accion'] as String? ?? 'PERMITIR',
      puntoAccesoId: datos['punto_acceso_id'] as int?,
      diasSemana: (datos['dias_semana'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [1, 2, 3, 4, 5],
      horaInicio: datos['hora_inicio'] as String? ?? '07:00',
      horaFin: datos['hora_fin'] as String? ?? '22:00',
      vigenteDesde: datos['vigente_desde'] != null
          ? DateTime.tryParse(datos['vigente_desde'] as String)
          : null,
      vigenteHasta: datos['vigente_hasta'] != null
          ? DateTime.tryParse(datos['vigente_hasta'] as String)
          : null,
      activo: (datos['activo'] as bool?) ?? true,
      creadoPor: datos['creado_por'] as int?,
      actualizadoPor: datos['actualizado_por'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'rol': rol,
        'estado_usuario': estadoUsuario,
        'accion': accion,
        'punto_acceso_id': puntoAccesoId,
        'dias_semana': diasSemana,
        'hora_inicio': horaInicio,
        'hora_fin': horaFin,
        if (vigenteDesde != null)
          'vigente_desde': vigenteDesde!.toIso8601String(),
        if (vigenteHasta != null)
          'vigente_hasta': vigenteHasta!.toIso8601String(),
        'activo': activo,
      };
}

