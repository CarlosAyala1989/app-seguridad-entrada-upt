/// Biometría (o PIN/patrón del teléfono) del propio dispositivo.
///
/// La huella o el rostro nunca salen del teléfono: la app solo recibe
/// "autenticado: sí/no".
abstract interface class AutenticadorLocal {
  /// `true` si el teléfono tiene biometría configurada y la app puede usarla.
  Future<bool> estaDisponible();

  /// Muestra el diálogo del sistema con [motivo]. `true` si se autenticó.
  Future<bool> autenticar(String motivo);
}
