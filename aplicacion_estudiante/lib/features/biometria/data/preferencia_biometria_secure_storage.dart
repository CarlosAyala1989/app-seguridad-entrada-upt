import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/repositories/preferencia_biometria_repository.dart';

/// Guarda solo "activado: sí/no". Nunca se guarda ninguna huella ni rostro.
final class PreferenciaBiometriaSecureStorage
    implements PreferenciaBiometriaRepository {
  const PreferenciaBiometriaSecureStorage({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  final FlutterSecureStorage _storage;
  static const _clave = 'upt_biometria_activada';

  @override
  Future<bool> estaActivada() async {
    try {
      return await _storage.read(key: _clave) == 'true';
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> guardar({required bool activada}) =>
      _storage.write(key: _clave, value: activada.toString());
}
