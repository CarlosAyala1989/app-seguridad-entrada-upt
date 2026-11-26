/// Páginas públicas del servicio. No se envían tokens ni datos personales
/// en las URL. Se pueden sustituir mediante --dart-define al compilar.
final class LegalConfig {
  const LegalConfig({
    this.privacidad = const String.fromEnvironment(
      'URL_PRIVACIDAD_UPT',
      defaultValue: 'https://ingreso-upt.fottuto.men/privacidad',
    ),
    this.soporte = const String.fromEnvironment(
      'URL_SOPORTE_UPT',
      defaultValue: 'https://ingreso-upt.fottuto.men/soporte',
    ),
    this.eliminarCuenta = const String.fromEnvironment(
      'URL_ELIMINAR_CUENTA_UPT',
      defaultValue: 'https://ingreso-upt.fottuto.men/eliminar-cuenta',
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
