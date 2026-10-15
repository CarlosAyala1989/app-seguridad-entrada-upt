final class PerfilDigital {
  const PerfilDigital({
    required this.nombreCompleto,
    required this.codigoInstitucional,
    required this.correoInstitucional,
    required this.rol,
    required this.escuela,
    required this.estadoVerificacion,
    required this.estadoAcceso,
    this.estadoUsuario = 'ACTIVO',
    this.puedeSolicitarCodigoQr = false,
    this.fotoUrl,
  });

  final String nombreCompleto;
  final String codigoInstitucional;
  final String correoInstitucional;
  final String rol;
  final String escuela;
  final String estadoVerificacion;
  final String estadoAcceso;

  /// `ACTIVO` o `INACTIVO`: si la cuenta está bloqueada, no puede ingresar.
  final String estadoUsuario;

  /// La API indica si la identidad cumple los requisitos para pedir un QR.
  final bool puedeSolicitarCodigoQr;
  final String? fotoUrl;

  bool get tieneDatosMinimos =>
      nombreCompleto.trim().isNotEmpty &&
      codigoInstitucional.trim().isNotEmpty &&
      correoInstitucional.trim().isNotEmpty &&
      rol.trim().isNotEmpty &&
      escuela.trim().isNotEmpty &&
      estadoVerificacion.trim().isNotEmpty &&
      estadoAcceso.trim().isNotEmpty;

  /// `true` solo si la identidad está verificada, la cuenta activa y el
  /// acceso autorizado: es lo que la persona necesita saber antes de ir a
  /// la puerta.
  bool get permiteIngreso =>
      estadoVerificacion == 'VERIFICADA' &&
      estadoUsuario == 'ACTIVO' &&
      estadoAcceso == 'AUTORIZADO';

  /// Motivo general por el que hoy no puede ingresar, o `null` si puede.
  String? get motivoSinIngreso {
    if (estadoVerificacion != 'VERIFICADA') {
      return 'Tu identidad todavía no está verificada.';
    }
    if (estadoUsuario != 'ACTIVO') return 'Tu cuenta no está activa.';
    if (estadoAcceso != 'AUTORIZADO') {
      return 'Tu acceso no está autorizado en este momento.';
    }
    return null;
  }
}
