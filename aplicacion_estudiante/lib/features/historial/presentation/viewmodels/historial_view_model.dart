import 'dart:async';

import '../../../../core/error/failure.dart';
import '../../../../shared/l10n/app_strings.dart';
import '../../domain/entities/registro_historial.dart';
import '../../domain/usecases/obtener_historial_use_case.dart';
import '../states/historial_state.dart';

final class HistorialViewModel {
  HistorialViewModel({required ObtenerHistorialUseCase obtenerHistorial})
    : _obtenerHistorial = obtenerHistorial;

  final ObtenerHistorialUseCase _obtenerHistorial;
  final StreamController<HistorialState> _states =
      StreamController<HistorialState>.broadcast();

  HistorialState currentState = const HistorialCargando();
  ResultadoIngreso? _filtro;
  int _pagina = 0;
  int _consulta = 0;
  final List<RegistroHistorial> _registros = [];

  Stream<HistorialState> get states => _states.stream;

  /// `null` = todos; si no, solo ingresos o solo rechazos.
  ResultadoIngreso? get filtro => _filtro;

  /// Carga desde la página 1, reemplazando la lista.
  Future<void> cargar() async {
    final consulta = ++_consulta;
    _emit(const HistorialCargando());
    try {
      final pagina = await _obtenerHistorial(resultado: _filtro);
      if (consulta != _consulta) return;
      _registros
        ..clear()
        ..addAll(pagina.registros);
      _pagina = pagina.pagina;
      _emit(
        _registros.isEmpty
            ? const HistorialVacio()
            : HistorialDatos(
                registros: List.unmodifiable(_registros),
                hayMas: pagina.hayMas,
              ),
      );
    } on Failure catch (f) {
      if (consulta == _consulta) _emit(HistorialError(f.message));
    } catch (_) {
      if (consulta == _consulta) {
        _emit(const HistorialError(AppStrings.unexpectedError));
      }
    }
  }

  Future<void> cambiarFiltro(ResultadoIngreso? filtro) {
    _filtro = filtro;
    return cargar();
  }

  /// Añade la página siguiente sin repetir registros ya mostrados.
  Future<void> cargarMas() async {
    final estado = currentState;
    if (estado is! HistorialDatos || !estado.hayMas || estado.cargandoMas) {
      return;
    }
    final consulta = _consulta;
    _emit(
      HistorialDatos(
        registros: estado.registros,
        hayMas: true,
        cargandoMas: true,
      ),
    );
    try {
      final pagina = await _obtenerHistorial(
        pagina: _pagina + 1,
        resultado: _filtro,
      );
      if (consulta != _consulta) return;
      final vistos = {for (final r in _registros) r.id};
      _registros.addAll(pagina.registros.where((r) => !vistos.contains(r.id)));
      _pagina = pagina.pagina;
      _emit(
        HistorialDatos(
          registros: List.unmodifiable(_registros),
          hayMas: pagina.hayMas,
        ),
      );
    } catch (error) {
      if (consulta != _consulta) return;
      _emit(
        HistorialDatos(
          registros: estado.registros,
          hayMas: true,
          mensaje: error is Failure ? error.message : AppStrings.unexpectedError,
        ),
      );
    }
  }

  void _emit(HistorialState state) {
    currentState = state;
    if (!_states.isClosed) _states.add(state);
  }

  Future<void> dispose() => _states.close();
}
