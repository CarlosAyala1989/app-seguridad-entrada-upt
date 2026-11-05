class IncidenciaModel {
  final int id;
  final int registroAccesoId;
  final int? responsableId;
  final String tipo;
  final String observacion;
  final String claveIdempotencia;
  final DateTime creadoEn;

  const IncidenciaModel({
    required this.id,
    required this.registroAccesoId,
    this.responsableId,
    required this.tipo,
    required this.observacion,
    required this.claveIdempotencia,
    required this.creadoEn,
  });

  String get tipoLegible {
    switch (tipo) {
      case 'PROBLEMA_QR':
        return 'Problema con código QR';
      case 'DOCUMENTO_NO_COINCIDE':
        return 'Documento no coincide con identidad';
      case 'SUPLANTACION':
        return 'Sospecha de suplantación de identidad';
      case 'OTRA':
      default:
        return 'Otra incidencia';
    }
  }

  factory IncidenciaModel.fromJson(Map<String, dynamic> json) {
    final datos = json['datos'] as Map<String, dynamic>? ?? json;
    return IncidenciaModel(
      id: datos['id'] as int? ?? 0,
      registroAccesoId: datos['registro_acceso_id'] as int? ?? 0,
      responsableId: datos['responsable_id'] as int?,
      tipo: datos['tipo'] as String? ?? 'OTRA',
      observacion: datos['observacion'] as String? ?? '',
      claveIdempotencia: datos['clave_idempotencia'] as String? ?? '',
      creadoEn: datos['creado_en'] != null
          ? DateTime.tryParse(datos['creado_en'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'registro_acceso_id': registroAccesoId,
        if (responsableId != null) 'responsable_id': responsableId,
        'tipo': tipo,
        'observacion': observacion,
        'clave_idempotencia': claveIdempotencia,
        'creado_en': creadoEn.toIso8601String(),
      };
}
