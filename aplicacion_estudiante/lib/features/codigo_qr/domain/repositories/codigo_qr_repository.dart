import '../../../ubicacion/domain/entities/ubicacion_dispositivo.dart';
import '../entities/codigo_qr.dart';

abstract interface class CodigoQrRepository {
  /// Pide a la API un QR nuevo, enviando la ubicación actual.
  Future<CodigoQr> generar(UbicacionDispositivo ubicacion);

  /// Anula el QR vigente para que ya no sirva en la puerta.
  Future<void> revocarActual();
}
