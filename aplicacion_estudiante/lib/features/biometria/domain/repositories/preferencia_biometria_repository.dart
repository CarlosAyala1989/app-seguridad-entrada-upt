/// Guarda si la persona activó el desbloqueo con biometría en este teléfono.
abstract interface class PreferenciaBiometriaRepository {
  Future<bool> estaActivada();

  Future<void> guardar({required bool activada});
}
