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
