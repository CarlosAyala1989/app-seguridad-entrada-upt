/// Páginas públicas que administra la institución. No se envían tokens ni
/// datos personales en las URL. Deben configurarse antes de distribuir.
final class LegalConfig {
  const LegalConfig({
    this.privacidad = const String.fromEnvironment('URL_PRIVACIDAD_UPT'),
    this.soporte = const String.fromEnvironment('URL_SOPORTE_UPT'),
    this.eliminarCuenta = const String.fromEnvironment(
      'URL_ELIMINAR_CUENTA_UPT',
    ),
  });

  final String privacidad;
  final String soporte;
  final String eliminarCuenta;

  static Uri? uriPublica(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      return null;
    }
    return uri;
  }
}
