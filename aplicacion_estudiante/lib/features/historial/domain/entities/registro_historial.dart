enum ResultadoIngreso { autorizado, denegado }

/// Un intento de ingreso propio, autorizado o rechazado (US-14).
final class RegistroHistorial {
  const RegistroHistorial({
    required this.id,
    required this.resultado,
    required this.motivo,
    required this.registradoEn,
    required this.puntoAccesoNombre,
  });

  final int id;
  final ResultadoIngreso resultado;

  /// Código técnico que envía la API, p. ej. `CREDENCIAL_YA_UTILIZADA`.
  final String motivo;
  final DateTime registradoEn;
  final String puntoAccesoNombre;

  bool get esAutorizado => resultado == ResultadoIngreso.autorizado;

  /// Motivo en lenguaje claro. Los códigos nuevos usan un texto genérico.
  String get motivoLegible =>
      _motivos[motivo] ??
      (esAutorizado ? 'Ingreso autorizado' : 'Ingreso rechazado');

  static const _motivos = {
    'ACCESO_AUTORIZADO': 'Ingreso autorizado',
    'CREDENCIAL_YA_UTILIZADA': 'El código QR ya se había usado',
    'CREDENCIAL_EXPIRADA': 'El código QR estaba vencido',
    'CREDENCIAL_REVOCADA': 'El código QR estaba anulado',
    'CODIGO_OFFLINE_NO_VIGENTE': 'El código sin conexión ya no era válido',
    'TOKEN_INVALIDO': 'El código QR no es válido',
    'INTEGRIDAD_CREDENCIAL_INVALIDA': 'El código QR no es válido',
    'USUARIO_NO_HABILITADO': 'Tu cuenta no estaba habilitada',
    'IDENTIDAD_NO_VERIFICADA': 'Tu identidad no estaba verificada',
    'ROL_PORTADOR_NO_HABILITADO': 'Tu rol no tiene acceso por esta puerta',
    'SESION_USUARIO_INVALIDA': 'Tu sesión no era válida',
    'DISPOSITIVO_NO_VINCULADO': 'El teléfono no estaba vinculado',
    'PUNTO_ACCESO_NO_COINCIDE': 'El código era para otra puerta',
    'PUNTO_ACCESO_INACTIVO': 'La puerta no estaba habilitada',
    'PUNTO_ACCESO_NO_ENCONTRADO': 'La puerta no estaba registrada',
    'UBICACION_ESCANEO_FUERA_DE_ZONA': 'El escaneo se hizo fuera de la zona',
  };
}

/// Una página del historial y lo necesario para pedir la siguiente.
final class PaginaHistorial {
  const PaginaHistorial({
    required this.registros,
    required this.pagina,
    required this.totalPaginas,
    required this.total,
  });

  final List<RegistroHistorial> registros;
  final int pagina;
  final int totalPaginas;
  final int total;

  bool get hayMas => pagina < totalPaginas;
}
