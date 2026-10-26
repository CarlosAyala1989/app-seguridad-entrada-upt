import 'dart:async';

import '../../../../core/error/failure.dart';
import '../../../../shared/l10n/app_strings.dart';
import '../../domain/entities/codigo_qr.dart';
import '../../domain/entities/vinculacion_qr_offline.dart';
import '../../domain/usecases/generar_codigo_qr_use_case.dart';
import '../../domain/usecases/qr_offline_use_cases.dart';
import '../../domain/usecases/revocar_codigo_qr_use_case.dart';
import '../states/codigo_qr_state.dart';

typedef CrearTemporizador =
    Timer Function(Duration intervalo, void Function(Timer) alSonar);

/// Genera el QR, lleva la cuenta regresiva y lo renueva solo al vencer.
///
/// Con internet usa el QR en línea (con ubicación). Si no hay red y el
/// teléfono ya está vinculado, muestra el QR sin conexión, que se calcula
/// en el propio teléfono.
final class CodigoQrViewModel {
  CodigoQrViewModel({
    required GenerarCodigoQrUseCase generarCodigoQr,
    required RevocarCodigoQrUseCase revocarCodigoQr,
    PrepararQrOfflineUseCase? prepararQrOffline,
    ObtenerVinculacionOfflineUseCase? obtenerVinculacionOffline,
    DateTime Function()? ahora,
    CrearTemporizador? crearTemporizador,
  }) : _generarCodigoQr = generarCodigoQr,
       _revocarCodigoQr = revocarCodigoQr,
       _prepararQrOffline = prepararQrOffline,
       _obtenerVinculacionOffline = obtenerVinculacionOffline,
       _ahora = ahora ?? DateTime.now,
       _crearTemporizador = crearTemporizador ?? Timer.periodic;

  final GenerarCodigoQrUseCase _generarCodigoQr;
  final RevocarCodigoQrUseCase _revocarCodigoQr;
  final PrepararQrOfflineUseCase? _prepararQrOffline;
  final ObtenerVinculacionOfflineUseCase? _obtenerVinculacionOffline;
  final DateTime Function() _ahora;
  final CrearTemporizador _crearTemporizador;
  final StreamController<CodigoQrState> _states =
      StreamController<CodigoQrState>.broadcast();

  CodigoQrState currentState = const CodigoQrInicial();
  CodigoQr? _codigo;
  VinculacionQrOffline? _vinculacion;
  Timer? _temporizador;
  bool _rotacionAutomatica = false;
  bool _descartado = false;

  Stream<CodigoQrState> get states => _states.stream;
  bool get rotacionAutomatica => _rotacionAutomatica;
  bool get admiteSinConexion => _obtenerVinculacionOffline != null;

  /// Vincula el teléfono para el QR sin conexión, si hay internet. Se llama
  /// una vez al abrir la pantalla; si falla, se sigue con lo guardado.
  Future<void> prepararSinConexion() async {
    final preparar = _prepararQrOffline;
    if (preparar == null || _descartado) return;
    try {
      await preparar();
    } catch (_) {
      // Un fallo aquí no debe molestar: el QR en línea sigue funcionando.
    }
  }

  /// Muestra el QR calculado en el teléfono, sin internet ni GPS.
  Future<void> generarSinConexion() async {
    final obtener = _obtenerVinculacionOffline;
    if (obtener == null || _descartado) return;
    _cancelarTemporizador();
    _codigo = null;
    _rotacionAutomatica = false;
    _emit(const CodigoQrCargando());
    try {
      final vinculacion = await obtener();
      if (_descartado) return;
      _vinculacion = vinculacion;
      _actualizarOffline();
      _temporizador = _crearTemporizador(
        const Duration(seconds: 1),
        (_) => _actualizarOffline(),
      );
    } on Failure catch (failure) {
      _emit(CodigoQrError(failure.message));
    } catch (_) {
      _emit(const CodigoQrError(AppStrings.qrGenerateError));
    }
  }

  /// Recalcula desde el reloj en cada tic: al volver del segundo plano se ve
  /// el código actual, no uno viejo.
  void _actualizarOffline() {
    final vinculacion = _vinculacion;
    if (vinculacion == null || _descartado) return;
    final ahora = _ahora();
    final codigo = vinculacion.generar(ahora);
    _emit(
      CodigoQrOfflineVisible(
        codigo: codigo,
        segundosRestantes: codigo.segundosRestantes(ahora),
      ),
    );
  }

  /// Pide un código nuevo. Con [rotacionAutomatica], al vencer se pide otro.
  Future<void> generar({bool rotacionAutomatica = true}) async {
    if (currentState is CodigoQrCargando || _descartado) return;
    _cancelarTemporizador();
    _vinculacion = null;
    _rotacionAutomatica = rotacionAutomatica;
    _emit(const CodigoQrCargando());
    try {
      final codigo = await _generarCodigoQr();
      if (_descartado) return;
      if (!codigo.estaVigente(_ahora())) {
        // Evita pedir códigos sin fin si el reloj del teléfono está mal.
        _rotacionAutomatica = false;
        _emit(const CodigoQrError(AppStrings.qrClockError));
        return;
      }
      _codigo = codigo;
      _actualizar();
      _temporizador = _crearTemporizador(
        const Duration(seconds: 1),
        (_) => _actualizar(),
      );
    } on NetworkFailure catch (failure) {
      _rotacionAutomatica = false;
      if (_descartado) return;
      if (admiteSinConexion) {
        // Sin internet: se pasa al QR calculado en el teléfono.
        await generarSinConexion();
      } else {
        _emit(CodigoQrError(failure.message));
      }
    } on Failure catch (failure) {
      _rotacionAutomatica = false;
      _emit(CodigoQrError(failure.message));
    } catch (_) {
      _rotacionAutomatica = false;
      _emit(const CodigoQrError(AppStrings.qrGenerateError));
    }
  }

  /// Anula el código en la API. Devuelve `true` si quedó anulado.
  Future<bool> revocar() async {
    final estado = currentState;
    if (estado is! CodigoQrVisible || estado.revocando) return false;
    _emit(
      CodigoQrVisible(
        codigo: estado.codigo,
        segundosRestantes: estado.segundosRestantes,
        revocando: true,
      ),
    );
    try {
      await _revocarCodigoQr();
      if (_descartado) return false;
      _rotacionAutomatica = false;
      _cancelarTemporizador();
      _codigo = null;
      _emit(const CodigoQrInicial());
      return true;
    } catch (error) {
      if (_descartado) return false;
      final codigo = _codigo;
      if (codigo != null) {
        _emit(
          CodigoQrVisible(
            codigo: codigo,
            segundosRestantes: codigo.segundosRestantes(_ahora()),
            mensaje: error is Failure
                ? error.message
                : AppStrings.qrRevokeError,
          ),
        );
      }
      return false;
    }
  }

  void _actualizar() {
    final codigo = _codigo;
    if (codigo == null || _descartado) return;
    final segundos = codigo.segundosRestantes(_ahora());
    if (segundos > 0) {
      final estado = currentState;
      _emit(
        CodigoQrVisible(
          codigo: codigo,
          segundosRestantes: segundos,
          revocando: estado is CodigoQrVisible && estado.revocando,
          mensaje: estado is CodigoQrVisible ? estado.mensaje : null,
        ),
      );
      return;
    }
    _cancelarTemporizador();
    _codigo = null;
    if (_rotacionAutomatica) {
      unawaited(generar());
    } else {
      _emit(const CodigoQrInicial());
    }
  }

  void _cancelarTemporizador() {
    _temporizador?.cancel();
    _temporizador = null;
  }

  void _emit(CodigoQrState state) {
    currentState = state;
    if (!_states.isClosed) _states.add(state);
  }

  Future<void> dispose() {
    _descartado = true;
    _cancelarTemporizador();
    return _states.close();
  }
}
