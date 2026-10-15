import '../../domain/entities/codigo_qr.dart';

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

final class CodigoQrError extends CodigoQrState {
  const CodigoQrError(this.message);

  final String message;
}
