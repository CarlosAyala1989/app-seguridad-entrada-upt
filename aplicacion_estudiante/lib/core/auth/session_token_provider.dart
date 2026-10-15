import 'secure_session_storage.dart';

abstract interface class SessionTokenProvider {
  Future<String?> readAccessToken();
}

/// Adaptador temporal para el taller. En producción se sustituye por una
/// implementación respaldada por el almacenamiento seguro de la plataforma.
final class DevelopmentSessionTokenProvider implements SessionTokenProvider {
  const DevelopmentSessionTokenProvider();

  @override
  Future<String?> readAccessToken() async {
    const token = String.fromEnvironment('DEMO_SESSION_TOKEN');
    return token.isEmpty ? null : token;
  }
}

/// Lee el token de acceso que el login guardó en el almacenamiento seguro.
final class SecureSessionTokenProvider implements SessionTokenProvider {
  const SecureSessionTokenProvider(this._sessionStorage);

  final SecureSessionStorage _sessionStorage;

  @override
  Future<String?> readAccessToken() async {
    final tokens = await _sessionStorage.leerTokens();
    return tokens?.tokenAcceso;
  }
}

/// Entrega un token de acceso vigente: si está por caducar, lo renueva antes
/// con el token de renovación. Si la renovación falla, borra la sesión local
/// y devuelve `null`, lo que obliga a iniciar sesión otra vez.
final class RenovableSessionTokenProvider implements SessionTokenProvider {
  RenovableSessionTokenProvider({
    required Future<SessionTokensData?> Function() leerTokens,
    required Future<void> Function() limpiar,
    required Future<String> Function(String tokenRenovacion) renovar,
    DateTime Function()? ahora,
    this.margen = const Duration(seconds: 30),
  }) : _leerTokens = leerTokens,
       _limpiar = limpiar,
       _renovar = renovar,
       _ahora = ahora ?? DateTime.now;

  final Future<SessionTokensData?> Function() _leerTokens;
  final Future<void> Function() _limpiar;
  final Future<String> Function(String tokenRenovacion) _renovar;
  final DateTime Function() _ahora;

  /// Tiempo antes de la expiración en el que el token ya se renueva, para que
  /// no caduque a mitad de una petición.
  final Duration margen;

  Future<String?>? _renovacionEnCurso;

  @override
  Future<String?> readAccessToken() async {
    final tokens = await _leerTokens();
    if (tokens == null) return null;

    final ahora = _ahora();
    if (!ahora.isBefore(tokens.tokenRenovacionExpiraEn)) {
      await _limpiar();
      return null;
    }
    if (ahora.add(margen).isBefore(tokens.tokenAccesoExpiraEn)) {
      return tokens.tokenAcceso;
    }

    // Varias peticiones a la vez comparten una sola renovación.
    return _renovacionEnCurso ??= _renovarUnaVez(tokens.tokenRenovacion)
        .whenComplete(() => _renovacionEnCurso = null);
  }

  Future<String?> _renovarUnaVez(String tokenRenovacion) async {
    try {
      return await _renovar(tokenRenovacion);
    } catch (_) {
      await _limpiar();
      return null;
    }
  }
}
