/// Credencial QR temporal emitida por la API.
///
/// [contenido] es un token opaco: no lleva nombre, correo, OTP ni
/// coordenadas legibles. Solo la API sabe a quién pertenece.
final class CodigoQr {
  const CodigoQr({
    required this.contenido,
    required this.estado,
    required this.emitidoEn,
    required this.expiraEn,
    required this.duracionSegundos,
    required this.unSoloUso,
    required this.puntoAccesoNombre,
  });

  final String contenido;
  final String estado;
  final DateTime emitidoEn;
  final DateTime expiraEn;
  final int duracionSegundos;
  final bool unSoloUso;
  final String puntoAccesoNombre;

  /// Segundos que le quedan, redondeados hacia arriba; nunca negativo.
  int segundosRestantes(DateTime ahora) {
    final ms = expiraEn.difference(ahora).inMilliseconds;
    return ms <= 0 ? 0 : (ms / Duration.millisecondsPerSecond).ceil();
  }

  bool estaVigente(DateTime ahora) => segundosRestantes(ahora) > 0;
}
