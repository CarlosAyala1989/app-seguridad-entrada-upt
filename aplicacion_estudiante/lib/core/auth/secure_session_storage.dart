import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final class SessionTokensData {
  const SessionTokensData({
    required this.tokenAcceso,
    required this.tokenRenovacion,
    required this.tokenAccesoExpiraEn,
    required this.tokenRenovacionExpiraEn,
  });

  final String tokenAcceso;
  final String tokenRenovacion;
  final DateTime tokenAccesoExpiraEn;
  final DateTime tokenRenovacionExpiraEn;

  bool get renovacionExpirada =>
      DateTime.now().isAfter(tokenRenovacionExpiraEn);

  bool get accesoExpirado => DateTime.now().isAfter(tokenAccesoExpiraEn);
}

final class SecureSessionStorage {
  const SecureSessionStorage({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  final FlutterSecureStorage _storage;

  static const _keyTokenAcceso = 'upt_token_acceso';
  static const _keyTokenRenovacion = 'upt_token_renovacion';
  static const _keyAccesoExpiraEn = 'upt_token_acceso_expira_en';
  static const _keyRenovacionExpiraEn = 'upt_token_renovacion_expira_en';

  /// Guarda de forma atómica los tokens y sus fechas de expiración.
  Future<void> guardarTokens({
    required String tokenAcceso,
    required String tokenRenovacion,
    required DateTime tokenAccesoExpiraEn,
    required DateTime tokenRenovacionExpiraEn,
  }) async {
    await Future.wait([
      _storage.write(key: _keyTokenAcceso, value: tokenAcceso),
      _storage.write(key: _keyTokenRenovacion, value: tokenRenovacion),
      _storage.write(
        key: _keyAccesoExpiraEn,
        value: tokenAccesoExpiraEn.toIso8601String(),
      ),
      _storage.write(
        key: _keyRenovacionExpiraEn,
        value: tokenRenovacionExpiraEn.toIso8601String(),
      ),
    ]);
  }

  /// Recupera los tokens persistidos si existen todos los valores requeridos.
  Future<SessionTokensData?> leerTokens() async {
    final tokenAcceso = await _storage.read(key: _keyTokenAcceso);
    final tokenRenovacion = await _storage.read(key: _keyTokenRenovacion);
    final accesoExpiraRaw = await _storage.read(key: _keyAccesoExpiraEn);
    final renovacionExpiraRaw = await _storage.read(
      key: _keyRenovacionExpiraEn,
    );

    if (tokenAcceso == null ||
        tokenRenovacion == null ||
        accesoExpiraRaw == null ||
        renovacionExpiraRaw == null) {
      return null;
    }

    try {
      final tokenAccesoExpiraEn = DateTime.parse(accesoExpiraRaw);
      final tokenRenovacionExpiraEn = DateTime.parse(renovacionExpiraRaw);

      return SessionTokensData(
        tokenAcceso: tokenAcceso,
        tokenRenovacion: tokenRenovacion,
        tokenAccesoExpiraEn: tokenAccesoExpiraEn,
        tokenRenovacionExpiraEn: tokenRenovacionExpiraEn,
      );
    } on FormatException {
      await limpiar();
      return null;
    }
  }

  /// Elimina por completo las claves de autenticación del dispositivo.
  Future<void> limpiar() async {
    await Future.wait([
      _storage.delete(key: _keyTokenAcceso),
      _storage.delete(key: _keyTokenRenovacion),
      _storage.delete(key: _keyAccesoExpiraEn),
      _storage.delete(key: _keyRenovacionExpiraEn),
    ]);
  }
}
