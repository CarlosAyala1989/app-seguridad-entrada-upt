import '../../domain/entities/codigo_qr.dart';
import '../../domain/entities/vinculacion_qr_offline.dart';

sealed class CodigoQrState {
  const CodigoQrState();
}

/// Aún no se pidió ningún código.
final class CodigoQrInicial extends CodigoQrState {
  const CodigoQrInicial();
}

final class CodigoQrCargando extends CodigoQrState {
  const CodigoQrCargando();
}

final class CodigoQrVisible extends CodigoQrState {
  const CodigoQrVisible({
    required this.codigo,
    required this.segundosRestantes,
    this.revocando = false,
    this.mensaje,
  });

  final CodigoQr codigo;
  final int segundosRestantes;
  final bool revocando;

  /// Aviso puntual (p. ej. no se pudo anular) sin ocultar el código.
  final String? mensaje;
}

/// QR calculado en el teléfono, sin internet ni GPS. Cambia cada
/// `periodoSegundos` sin pedir nada a la API.
final class CodigoQrOfflineVisible extends CodigoQrState {
  const CodigoQrOfflineVisible({
    required this.codigo,
    required this.segundosRestantes,
  });

  final CodigoQrOffline codigo;
  final int segundosRestantes;
}

final class CodigoQrError extends CodigoQrState {
  const CodigoQrError(this.message);

  final String message;
}
