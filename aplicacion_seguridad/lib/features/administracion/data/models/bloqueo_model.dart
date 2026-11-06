class BloqueoModel {
  final int id;
  final int usuarioId;
  final String motivo;
  final int creadoPor;
  final DateTime vigenteDesde;
  final DateTime? vigenteHasta;
  final DateTime? rehabilitadoEn;
  final int? rehabilitadoPor;
  final String? motivoRehabilitacion;
  final bool vigente;

  const BloqueoModel({
    required this.id,
    required this.usuarioId,
    required this.motivo,
    required this.creadoPor,
    required this.vigenteDesde,
    this.vigenteHasta,
    this.rehabilitadoEn,
    this.rehabilitadoPor,
    this.motivoRehabilitacion,
    this.vigente = true,
  });

  bool get estaRehabilitado => rehabilitadoEn != null;
  bool get esVigente => vigente && !estaRehabilitado;

  factory BloqueoModel.fromJson(Map<String, dynamic> json) {
    final datos = json['datos'] as Map<String, dynamic>? ?? json;

    return BloqueoModel(
      id: datos['id'] as int? ?? 0,
      usuarioId: datos['usuario_id'] as int? ?? 0,
      motivo: datos['motivo'] as String? ?? '',
      creadoPor: datos['creado_por'] as int? ?? 0,
      vigenteDesde: datos['vigente_desde'] != null
          ? DateTime.tryParse(datos['vigente_desde'] as String) ?? DateTime.now()
          : DateTime.now(),
      vigenteHasta: datos['vigente_hasta'] != null
          ? DateTime.tryParse(datos['vigente_hasta'] as String)
          : null,
      rehabilitadoEn: datos['rehabilitado_en'] != null
          ? DateTime.tryParse(datos['rehabilitado_en'] as String)
          : null,
      rehabilitadoPor: datos['rehabilitado_por'] as int?,
      motivoRehabilitacion: datos['motivo_rehabilitacion'] as String?,
      vigente: (datos['vigente'] as bool?) ??
          (datos['rehabilitado_en'] == null),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'usuario_id': usuarioId,
        'motivo': motivo,
        'creado_por': creadoPor,
        'vigente_desde': vigenteDesde.toIso8601String(),
        if (vigenteHasta != null)
          'vigente_hasta': vigenteHasta!.toIso8601String(),
        if (rehabilitadoEn != null)
          'rehabilitado_en': rehabilitadoEn!.toIso8601String(),
        if (rehabilitadoPor != null) 'rehabilitado_por': rehabilitadoPor,
        if (motivoRehabilitacion != null)
          'motivo_rehabilitacion': motivoRehabilitacion,
        'vigente': vigente,
      };
}
