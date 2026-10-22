import '../failures/biometria_failure.dart';
import '../repositories/autenticador_local.dart';
import '../repositories/preferencia_biometria_repository.dart';

/// Reglas del bloqueo local con biometría (US-22).
///
/// Solo protege una sesión ya iniciada: no reemplaza el inicio de sesión
/// institucional con intranet y Google.
final class BloqueoBiometricoUseCase {
  const BloqueoBiometricoUseCase({
    required AutenticadorLocal autenticador,
    required PreferenciaBiometriaRepository preferencias,
    required Future<bool> Function() haySesion,
  }) : _autenticador = autenticador,
       _preferencias = preferencias,
       _haySesion = haySesion;

  final AutenticadorLocal _autenticador;
  final PreferenciaBiometriaRepository _preferencias;
  final Future<bool> Function() _haySesion;

  static const motivoDesbloqueo =
      'Confirma que eres tú para ver tu identidad digital';
  static const motivoActivacion =
      'Confirma tu huella o rostro para activar el desbloqueo';

  Future<bool> estaDisponible() => _autenticador.estaDisponible();

  Future<bool> estaActivada() => _preferencias.estaActivada();

  /// Hay que bloquear solo si la persona lo activó, hay una sesión que
  /// proteger y el teléfono todavía tiene biometría disponible.
  Future<bool> debeBloquear() async {
    if (!await _preferencias.estaActivada()) return false;
    if (!await _haySesion()) return false;
    return _autenticador.estaDisponible();
  }

  Future<bool> desbloquear() => _autenticador.autenticar(motivoDesbloqueo);

  /// Activa el desbloqueo tras comprobar la huella una vez. Devuelve `false`
  /// si la persona cancela; lanza [BiometriaNoDisponibleFailure] si el
  /// teléfono no lo permite.
  Future<bool> activar() async {
    if (!await _autenticador.estaDisponible()) {
      throw const BiometriaNoDisponibleFailure();
    }
    if (!await _autenticador.autenticar(motivoActivacion)) return false;
    await _preferencias.guardar(activada: true);
    return true;
  }

  Future<void> desactivar() => _preferencias.guardar(activada: false);
}
