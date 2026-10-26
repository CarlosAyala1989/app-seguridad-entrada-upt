import 'dart:async';

import '../../../../core/error/failure.dart';
import '../../../../shared/l10n/app_strings.dart';
import '../../domain/entities/notificacion.dart';
import '../../domain/usecases/notificaciones_use_cases.dart';
import '../states/bandeja_state.dart';

final class BandejaViewModel {
  BandejaViewModel({
    required ObtenerNotificacionesUseCase obtenerNotificaciones,
    TipoNotificacion? filtroInicial,
  }) : _obtenerNotificaciones = obtenerNotificaciones,
       _filtro = filtroInicial;

  final ObtenerNotificacionesUseCase _obtenerNotificaciones;
  final StreamController<BandejaState> _states =
      StreamController<BandejaState>.broadcast();

  BandejaState currentState = const BandejaCargando();
  TipoNotificacion? _filtro;
  int _pagina = 0;
  int _consulta = 0;
  final List<Notificacion> _items = [];

  Stream<BandejaState> get states => _states.stream;
  TipoNotificacion? get filtro => _filtro;

  /// Carga desde la página 1, reemplazando la lista.
  Future<void> cargar() async {
    final consulta = ++_consulta;
    _emit(const BandejaCargando());
    try {
      final pagina = await _obtenerNotificaciones(tipo: _filtro);
      if (consulta != _consulta) return;
      _items
        ..clear()
        ..addAll(pagina.notificaciones);
      _pagina = pagina.pagina;
      _emitirLista(hayMas: pagina.hayMas);
    } on Failure catch (f) {
      if (consulta == _consulta) _emit(BandejaError(f.message));
    } catch (_) {
      if (consulta == _consulta) {
        _emit(const BandejaError(AppStrings.unexpectedError));
      }
    }
  }

  Future<void> cambiarFiltro(TipoNotificacion? filtro) {
    _filtro = filtro;
    return cargar();
  }

  /// Añade la página siguiente sin repetir avisos (pueden llegar nuevos
  /// mientras se consulta).
  Future<void> cargarMas() async {
    final estado = currentState;
    if (estado is! BandejaDatos || !estado.hayMas || estado.cargandoMas) {
      return;
    }
    final consulta = _consulta;
    _emit(
      BandejaDatos(
        notificaciones: estado.notificaciones,
        hayMas: true,
        cargandoMas: true,
      ),
    );
    try {
      final pagina = await _obtenerNotificaciones(
        pagina: _pagina + 1,
        tipo: _filtro,
      );
      if (consulta != _consulta) return;
      final vistos = {for (final n in _items) n.id};
      _items.addAll(pagina.notificaciones.where((n) => !vistos.contains(n.id)));
      _pagina = pagina.pagina;
      _emitirLista(hayMas: pagina.hayMas);
    } catch (error) {
      if (consulta != _consulta) return;
      _emit(
        BandejaDatos(
          notificaciones: estado.notificaciones,
          hayMas: true,
          mensaje: error is Failure ? error.message : AppStrings.unexpectedError,
        ),
      );
    }
  }

  /// Sustituye un aviso que cambió (p. ej. tras marcarlo como leído).
  void actualizar(Notificacion notificacion) {
    final i = _items.indexWhere((n) => n.id == notificacion.id);
    if (i < 0) return;
    _items[i] = notificacion;
    final estado = currentState;
    if (estado is BandejaDatos) _emitirLista(hayMas: estado.hayMas);
  }

  void _emitirLista({required bool hayMas}) {
    _emit(
      _items.isEmpty
          ? const BandejaVacia()
          : BandejaDatos(
              notificaciones: List.unmodifiable(_items),
              hayMas: hayMas,
            ),
    );
  }

  void _emit(BandejaState state) {
    currentState = state;
    if (!_states.isClosed) _states.add(state);
  }

  Future<void> dispose() => _states.close();
}
