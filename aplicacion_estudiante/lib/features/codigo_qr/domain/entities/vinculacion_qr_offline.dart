import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Vinculación de este teléfono para generar el QR sin internet.
///
/// La API la entrega una sola vez con conexión (`POST
/// /codigos-qr/preparar-offline`) y después el teléfono calcula los códigos
/// solo, con el [secreto]. El guardia, que sí está conectado, envía el código
/// a la API y ella decide si es válido.
final class VinculacionQrOffline {
  const VinculacionQrOffline({
    required this.usuarioId,
    required this.dispositivoId,
    required this.secreto,
    required this.periodoSegundos,
    required this.desfaseRelojMs,
  });

  static const prefijo = 'upt_offline_v2';

  /// Cuenta a la que pertenece: nunca se usa la vinculación de otra cuenta.
  final int usuarioId;

  /// ID que la API asignó a este teléfono; va dentro del QR.
  final int dispositivoId;

  /// 32 bytes en Base64URL sin `=`. No se muestra ni se escribe en logs.
  final String secreto;

  /// Cada cuántos segundos cambia el código (hoy, 15).
  final int periodoSegundos;

  /// Hora del servidor menos hora del teléfono al vincular, para que los
  /// dos calculen el mismo intervalo aunque el reloj del teléfono esté
  /// un poco corrido.
  final int desfaseRelojMs;

  /// Calcula el código vigente en [ahora] (algoritmo `upt_offline_v2`).
  ///
  /// 1. Intervalo: `(ahora + desfase) / periodo`, sin decimales.
  /// 2. Mensaje: `upt_offline_v2.<dispositivo>.<intervalo>`.
  /// 3. Firma: HMAC-SHA256 del mensaje con el secreto.
  /// 4. OTP de 6 cifras con el truncado dinámico de la firma (como en TOTP).
  /// 5. QR: `<mensaje>.<otp>.<firma en Base64URL sin =>`.
  CodigoQrOffline generar(DateTime ahora) {
    final periodoMs = periodoSegundos * 1000;
    final ajustadoMs = ahora.millisecondsSinceEpoch + desfaseRelojMs;
    final paso = ajustadoMs ~/ periodoMs;

    final mensaje = '$prefijo.$dispositivoId.$paso';
    final firma = Hmac(
      sha256,
      _decodificarBase64Url(secreto),
    ).convert(utf8.encode(mensaje)).bytes;

    final desplazamiento = firma[31] & 0x0f;
    final valor =
        ((firma[desplazamiento] & 0x7f) << 24) |
        (firma[desplazamiento + 1] << 16) |
        (firma[desplazamiento + 2] << 8) |
        firma[desplazamiento + 3];
    final otp = (valor % 1000000).toString().padLeft(6, '0');
    final firmaTexto = base64Url.encode(firma).replaceAll('=', '');

    // Fin del intervalo en la hora del servidor, pasado a la del teléfono.
    final finIntervaloMs = (paso + 1) * periodoMs - desfaseRelojMs;

    return CodigoQrOffline(
      contenido: '$mensaje.$otp.$firmaTexto',
      otp: otp,
      pasoTiempo: paso,
      expiraEn: DateTime.fromMillisecondsSinceEpoch(finIntervaloMs),
      periodoSegundos: periodoSegundos,
    );
  }

  /// Base64URL sin relleno → bytes (se agrega el `=` que falte).
  static List<int> _decodificarBase64Url(String texto) {
    final faltan = (4 - texto.length % 4) % 4;
    return base64Url.decode(texto + '=' * faltan);
  }
}

/// Un código offline ya calculado, listo para dibujar.
final class CodigoQrOffline {
  const CodigoQrOffline({
    required this.contenido,
    required this.otp,
    required this.pasoTiempo,
    required this.expiraEn,
    required this.periodoSegundos,
  });

  /// Texto completo que va en el QR.
  final String contenido;

  /// 6 cifras para mostrar como referencia (no autorizan nada solas).
  final String otp;
  final int pasoTiempo;
  final DateTime expiraEn;
  final int periodoSegundos;

  int segundosRestantes(DateTime ahora) {
    final ms = expiraEn.difference(ahora).inMilliseconds;
    if (ms <= 0) return 0;
    return (ms + 999) ~/ 1000;
  }
}
