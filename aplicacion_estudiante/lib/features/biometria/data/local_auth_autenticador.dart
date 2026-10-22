import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import '../domain/repositories/autenticador_local.dart';

/// Usa `local_auth`. En web no hay biometría: se informa como no disponible.
final class LocalAuthAutenticador implements AutenticadorLocal {
  LocalAuthAutenticador({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> estaDisponible() async {
    if (kIsWeb) return false;
    try {
      return await _auth.isDeviceSupported() && await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> autenticar(String motivo) async {
    try {
      return await _auth.authenticate(
        localizedReason: motivo,
        // Si la huella falla, el sistema deja usar el PIN o patrón.
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } catch (_) {
      return false;
    }
  }
}
