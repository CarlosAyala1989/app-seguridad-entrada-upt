/// Utilidad de saneamiento y validación de entradas del usuario.
///
/// Dart puro: no importa Flutter (widgets) ni bibliotecas de red,
/// por lo que puede probarse y reutilizarse sin UI ni HTTP.
final class InputSanitizer {
  const InputSanitizer._();

  // Caracteres de control no imprimibles, excepto los que son espacios
  // en blanco (tab, salto de línea, etc.), que se tratan aparte.
  static final RegExp _controlNoImprimible = RegExp(
    r'[\u0000-\u0008\u000E-\u001F\u007F-\u009F]',
  );
  static final RegExp _espacios = RegExp(r'\s+');
  static final RegExp _codigoInstitucional = RegExp(r'^\d{10}$');

  /// Quita caracteres de control, colapsa espacios/tabulaciones repetidos
  /// en un solo espacio y elimina los espacios de los extremos.
  static String sanitize(String? input) {
    if (input == null) return '';
    return input
        .replaceAll(_controlNoImprimible, '')
        .replaceAll(_espacios, ' ')
        .trim();
  }

  /// Igual que [sanitize], pero elimina también los espacios internos.
  /// Pensado para códigos (ej. código institucional).
  static String sanitizeCodigo(String? input) {
    return sanitize(input).replaceAll(' ', '');
  }

  /// Regla de negocio: el código institucional debe tener exactamente
  /// 10 dígitos numéricos (tras sanear la entrada).
  static bool esCodigoInstitucionalValido(String? input) {
    return _codigoInstitucional.hasMatch(sanitizeCodigo(input));
  }
}