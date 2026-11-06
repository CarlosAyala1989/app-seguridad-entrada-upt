class RegistroHistorialModel {
  final String id;
  final String resultado; // 'AUTORIZADO' o 'DENEGADO'
  final String motivo;
  final String? nombreCompleto;
  final String? codigoInstitucional;
  final String? codigoEnmascarado;
  final String? escuela;
  final String puntoAccesoNombre;
  final String puntoAccesoCodigo;
  final DateTime fechaHora;
  final String? observacion;
  final int? turnoId;

  const RegistroHistorialModel({
    required this.id,
    required this.resultado,
    required this.motivo,
    this.nombreCompleto,
    this.codigoInstitucional,
    this.codigoEnmascarado,
    this.escuela,
    required this.puntoAccesoNombre,
    required this.puntoAccesoCodigo,
    required this.fechaHora,
    this.observacion,
    this.turnoId,
  });

  bool get esAutorizado => resultado == 'AUTORIZADO';

  int? get idNumerico => int.tryParse(id.replaceAll(RegExp(r'[^0-9]'), ''));

  String get motivoLegible {
    switch (motivo) {
      case 'ACCESO_AUTORIZADO':
        return 'Acceso permitido';
      case 'CREDENCIAL_YA_UTILIZADA':
        return 'Credencial QR ya utilizada';
      case 'CREDENCIAL_EXPIRADA':
      case 'QR_EXPIRADO':
        return 'Tiempo de vigencia QR expirado';
      case 'HORARIO_NO_PERMITIDO':
      case 'FUERA_HORARIO_PERMITIDO':
        return 'Fuera de franja horaria permitida';
      case 'UBICACION_INVALIDA':
      case 'FUERA_DE_ZONA':
      case 'GEOCERCA_INVALIDA':
        return 'Generado fuera del perímetro del campus';
      case 'USUARIO_BLOQUEADO':
        return 'Usuario con restricción temporal';
      case 'REGLA_ACCESO_DENEGADA':
        return 'Acceso restringido por regla institucional';
      case 'DATOS_IDENTIDAD_INCOMPLETOS':
        return 'Datos de identidad incompletos';
      default:
        return motivo.replaceAll('_', ' ');
    }
  }

  factory RegistroHistorialModel.fromJson(Map<String, dynamic> json) {
    final punto = json['punto_acceso'] as Map<String, dynamic>?;
    final usuario = json['usuario'] as Map<String, dynamic>?;

    final puntoNombre = punto?['nombre'] as String? ??
        json['punto_acceso_nombre'] as String? ??
        'Puerta Principal - Campus Capanique';
    final puntoCodigo = punto?['codigo'] as String? ??
        json['punto_acceso_codigo'] as String? ??
        'PUERTA-PRINCIPAL';

    final codEnmascarado = usuario?['codigo_enmascarado'] as String? ??
        json['codigo_enmascarado'] as String?;
    final codInst = codEnmascarado ?? json['codigo_institucional'] as String?;

    return RegistroHistorialModel(
      id: json['id'] != null ? json['id'].toString() : '',
      resultado: json['resultado'] as String? ?? 'DENEGADO',
      motivo: json['motivo'] as String? ?? 'SIN_MOTIVO',
      nombreCompleto: json['nombre_completo'] as String? ??
          (codEnmascarado != null ? 'Titular $codEnmascarado' : null),
      codigoInstitucional: codInst,
      codigoEnmascarado: codEnmascarado,
      escuela: json['escuela'] as String?,
      puntoAccesoNombre: puntoNombre,
      puntoAccesoCodigo: puntoCodigo,
      fechaHora: json['registrado_en'] != null
          ? DateTime.tryParse(json['registrado_en'] as String) ?? DateTime.now()
          : DateTime.now(),
      observacion: json['observacion'] as String?,
      turnoId: json['turno_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'resultado': resultado,
      'motivo': motivo,
      if (nombreCompleto != null) 'nombre_completo': nombreCompleto,
      if (codigoInstitucional != null)
        'codigo_institucional': codigoInstitucional,
      if (codigoEnmascarado != null) 'codigo_enmascarado': codigoEnmascarado,
      if (escuela != null) 'escuela': escuela,
      'punto_acceso_nombre': puntoAccesoNombre,
      'punto_acceso_codigo': puntoAccesoCodigo,
      'registrado_en': fechaHora.toIso8601String(),
      if (observacion != null) 'observacion': observacion,
      if (turnoId != null) 'turno_id': turnoId,
    };
  }

  /// Lista inicial demostrativa con registros recientes del turno operativo
  static List<RegistroHistorialModel> obtenerRegistrosIniciales() {
    final ahora = DateTime.now();
    return [
      RegistroHistorialModel(
        id: 'VAL-001',
        resultado: 'AUTORIZADO',
        motivo: 'ACCESO_AUTORIZADO',
        nombreCompleto: 'María Elena Pérez Quispe',
        codigoInstitucional: '2023071234',
        escuela: 'Ingeniería de Sistemas',
        puntoAccesoNombre: 'Puerta Principal - Campus Capanique',
        puntoAccesoCodigo: 'PUERTA-PRINCIPAL',
        fechaHora: ahora.subtract(const Duration(minutes: 4)),
        observacion: 'Acceso regular con código QR',
      ),
      RegistroHistorialModel(
        id: 'VAL-002',
        resultado: 'DENEGADO',
        motivo: 'CREDENCIAL_YA_UTILIZADA',
        nombreCompleto: null,
        codigoInstitucional: null,
        escuela: null,
        puntoAccesoNombre: 'Puerta Principal - Campus Capanique',
        puntoAccesoCodigo: 'PUERTA-PRINCIPAL',
        fechaHora: ahora.subtract(const Duration(minutes: 12)),
        observacion: 'Intento de reutilización de QR',
      ),
      RegistroHistorialModel(
        id: 'VAL-003',
        resultado: 'AUTORIZADO',
        motivo: 'ACCESO_AUTORIZADO',
        nombreCompleto: 'Jean Carlo Huanca Mamani',
        codigoInstitucional: '2021069812',
        escuela: 'Ingeniería Civil',
        puntoAccesoNombre: 'Puerta Principal - Campus Capanique',
        puntoAccesoCodigo: 'PUERTA-PRINCIPAL',
        fechaHora: ahora.subtract(const Duration(minutes: 25)),
      ),
      RegistroHistorialModel(
        id: 'VAL-004',
        resultado: 'DENEGADO',
        motivo: 'CREDENCIAL_EXPIRADA',
        nombreCompleto: null,
        codigoInstitucional: null,
        escuela: null,
        puntoAccesoNombre: 'Puerta Principal - Campus Capanique',
        puntoAccesoCodigo: 'PUERTA-PRINCIPAL',
        fechaHora: ahora.subtract(const Duration(minutes: 38)),
        observacion: 'Código generado hace más de 60 segundos',
      ),
      RegistroHistorialModel(
        id: 'VAL-005',
        resultado: 'AUTORIZADO',
        motivo: 'ACCESO_AUTORIZADO',
        nombreCompleto: 'Luciana Andrea Flores Castro',
        codigoInstitucional: '2022080045',
        escuela: 'Derecho y Ciencias Políticas',
        puntoAccesoNombre: 'Puerta Principal - Campus Capanique',
        puntoAccesoCodigo: 'PUERTA-PRINCIPAL',
        fechaHora: ahora.subtract(const Duration(hours: 1, minutes: 5)),
      ),
      RegistroHistorialModel(
        id: 'VAL-006',
        resultado: 'DENEGADO',
        motivo: 'UBICACION_INVALIDA',
        nombreCompleto: null,
        codigoInstitucional: null,
        escuela: null,
        puntoAccesoNombre: 'Puerta Principal - Campus Capanique',
        puntoAccesoCodigo: 'PUERTA-PRINCIPAL',
        fechaHora: ahora.subtract(const Duration(hours: 1, minutes: 20)),
        observacion: 'Ubicación reportada fuera del campus',
      ),
      RegistroHistorialModel(
        id: 'VAL-007',
        resultado: 'AUTORIZADO',
        motivo: 'ACCESO_AUTORIZADO',
        nombreCompleto: 'Rodrigo Sebastián Ticona Ramos',
        codigoInstitucional: '2020054321',
        escuela: 'Arquitectura y Urbanismo',
        puntoAccesoNombre: 'Puerta Principal - Campus Capanique',
        puntoAccesoCodigo: 'PUERTA-PRINCIPAL',
        fechaHora: ahora.subtract(const Duration(hours: 1, minutes: 45)),
      ),
    ];
  }
}
