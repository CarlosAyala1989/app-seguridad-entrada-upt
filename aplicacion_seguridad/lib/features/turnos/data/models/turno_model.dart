class TurnoModel {
  final int id;
  final int usuarioSeguridadId;
  final int puntoAccesoId;
  final String? puntoAccesoCodigo;
  final DateTime iniciadoEn;
  final DateTime? cerradoEn;

  const TurnoModel({
    required this.id,
    required this.usuarioSeguridadId,
    required this.puntoAccesoId,
    this.puntoAccesoCodigo,
    required this.iniciadoEn,
    this.cerradoEn,
  });

  bool get estaAbierto => cerradoEn == null;

  factory TurnoModel.fromJson(Map<String, dynamic> json) {
    final datos = json['datos'] as Map<String, dynamic>? ?? json;
    return TurnoModel(
      id: datos['id'] as int? ?? 0,
      usuarioSeguridadId: datos['usuario_seguridad_id'] as int? ?? 0,
      puntoAccesoId: datos['punto_acceso_id'] as int? ?? 0,
      puntoAccesoCodigo: datos['punto_acceso_codigo'] as String?,
      iniciadoEn: datos['iniciado_en'] != null
          ? DateTime.tryParse(datos['iniciado_en'] as String) ?? DateTime.now()
          : DateTime.now(),
      cerradoEn: datos['cerrado_en'] != null
          ? DateTime.tryParse(datos['cerrado_en'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'usuario_seguridad_id': usuarioSeguridadId,
        'punto_acceso_id': puntoAccesoId,
        if (puntoAccesoCodigo != null) 'punto_acceso_codigo': puntoAccesoCodigo,
        'iniciado_en': iniciadoEn.toIso8601String(),
        if (cerradoEn != null) 'cerrado_en': cerradoEn!.toIso8601String(),
      };
}

