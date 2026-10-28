import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/vinculacion_qr_offline.dart';

/// Guarda en el almacenamiento seguro el identificador de esta instalación y
/// la vinculación del QR sin conexión.
final class QrOfflineLocalDataSource {
  QrOfflineLocalDataSource({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
    Random? random,
  }) : _storage = storage,
       _random = random ?? Random.secure();

  final FlutterSecureStorage _storage;
  final Random _random;

  static const _keyIdentificador = 'upt_qr_offline_identificador';
  static const _keyVinculacion = 'upt_qr_offline_vinculacion';

  /// Identificador de esta instalación: 32 bytes aleatorios en Base64URL sin
  /// `=` (43 caracteres). Se crea una vez y se reutiliza.
  Future<String> identificadorDispositivo() async {
    final guardado = await _storage.read(key: _keyIdentificador);
    if (guardado != null && guardado.length == 43) return guardado;
    final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
    final nuevo = base64Url.encode(bytes).replaceAll('=', '');
    await _storage.write(key: _keyIdentificador, value: nuevo);
    return nuevo;
  }

  Future<void> guardar(VinculacionQrOffline vinculacion) {
    return _storage.write(
      key: _keyVinculacion,
      value: jsonEncode({
        'usuario_id': vinculacion.usuarioId,
        'dispositivo_id': vinculacion.dispositivoId,
        'secreto': vinculacion.secreto,
        'periodo_segundos': vinculacion.periodoSegundos,
        'desfase_reloj_ms': vinculacion.desfaseRelojMs,
      }),
    );
  }

  /// La vinculación guardada, o `null` si no hay o está dañada.
  Future<VinculacionQrOffline?> leer() async {
    try {
      final texto = await _storage.read(key: _keyVinculacion);
      if (texto == null) return null;
      final json = jsonDecode(texto);
      if (json is! Map<String, dynamic>) return null;
      return VinculacionQrOffline(
        usuarioId: json['usuario_id'] as int,
        dispositivoId: json['dispositivo_id'] as int,
        secreto: json['secreto'] as String,
        periodoSegundos: json['periodo_segundos'] as int,
        desfaseRelojMs: json['desfase_reloj_ms'] as int,
      );
    } catch (_) {
      return null;
    }
  }

  /// Borra la vinculación y el identificador (al cerrar sesión).
  Future<void> borrar() async {
    await _storage.delete(key: _keyVinculacion);
    await _storage.delete(key: _keyIdentificador);
  }
}
