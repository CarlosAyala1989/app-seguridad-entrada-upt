import 'dart:async';

import '../../../../core/error/failure.dart';
import '../../../../shared/l10n/app_strings.dart';
import '../../domain/entities/codigo_qr.dart';
import '../../domain/usecases/generar_codigo_qr_use_case.dart';
import '../../domain/usecases/revocar_codigo_qr_use_case.dart';
import '../states/codigo_qr_state.dart';

typedef CrearTemporizador =
    Timer Function(Duration intervalo, void Function(Timer) alSonar);

/// Genera el QR, lleva la cuenta regresiva y lo renueva solo al vencer.
final class CodigoQrViewModel {
  CodigoQrViewModel({
    required GenerarCodigoQrUseCase generarCodigoQr,
    required RevocarCodigoQrUseCase revocarCodigoQr,
    DateTime Function()? ahora,
    CrearTemporizador? crearTemporizador,
  }) : _generarCodigoQr = generarCodigoQr,
       _revocarCodigoQr = revocarCodigoQr,
       _ahora = ahora ?? DateTime.now,
       _crearTemporizador = crearTemporizador ?? Timer.periodic;

  final GenerarCodigoQrUseCase _generarCodigoQr;
  final RevocarCodigoQrUseCase _revocarCodigoQr;
  final DateTime Function() _ahora;
  final CrearTemporizador _crearTemporizador;
  final StreamController<CodigoQrState> _states =
      StreamController<CodigoQrState>.broadcast();

  CodigoQrState currentState = const CodigoQrInicial();
  CodigoQr? _codigo;
  Timer? _temporizador;
  bool _rotacionAutomatica = false;
  bool _descartado = false;

  Stream<CodigoQrState> get states => _states.stream;
  bool get rotacionAutomatica => _rotacionAutomatica;

  /// Pide un código nuevo. Con [rotacionAutomatica], al vencer se pide otro.
  Future<void> generar({bool rotacionAutomatica = true}) async {
    if (currentState is CodigoQrCargando || _descartado) return;
    _cancelarTemporizador();
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
            mensaje: error is Failure ? error.message : AppStrings.qrRevokeError,
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
