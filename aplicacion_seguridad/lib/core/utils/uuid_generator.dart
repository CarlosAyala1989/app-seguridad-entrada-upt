import 'dart:math';

/// Generador de identificadores UUID v4 estricto (RFC 4122) en Dart puro.
/// Utilizado para claves de idempotencia (`clave_idempotencia`) en registros de incidencias.
class UuidGenerator {
  static final Random _random = Random.secure();

  static String v4() => nuevoV4();

  static String nuevoV4() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));

    // Ajustar bits para versión 4 (bits 4-7 del byte 6 en 0100)
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    // Ajustar bits para variante RFC 4122 (bits 6-7 del byte 8 en 10)
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    String aHex(List<int> slice) =>
        slice.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    return '${aHex(bytes.sublist(0, 4))}-'
        '${aHex(bytes.sublist(4, 6))}-'
        '${aHex(bytes.sublist(6, 8))}-'
        '${aHex(bytes.sublist(8, 10))}-'
        '${aHex(bytes.sublist(10, 16))}';
  }
}
