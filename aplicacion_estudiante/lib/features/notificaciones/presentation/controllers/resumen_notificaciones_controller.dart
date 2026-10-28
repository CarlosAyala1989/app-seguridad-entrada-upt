import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../domain/entities/notificacion.dart';
import '../../domain/usecases/notificaciones_use_cases.dart';

typedef CrearTemporizadorPeriodico =
    Timer Function(Duration intervalo, void Function(Timer) alSonar);

/// Consulta los avisos pendientes mientras la app está en primer plano
/// (cada 25 s, como recomienda la API) y avisa de los que llegan nuevos.
///
/// Se detiene al pasar a segundo plano y al descartarse (cerrar sesión):
/// los avisos siguen guardados en el servidor y se ven al volver.
class ResumenNotificacionesController extends ChangeNotifier
    with WidgetsBindingObserver {
  ResumenNotificacionesController({
    required ConsultarResumenNotificacionesUseCase consultarResumen,
    required ObtenerNotificacionesUseCase obtenerNotificaciones,
    this.intervalo = const Duration(seconds: 25),
    CrearTemporizadorPeriodico? crearTemporizador,
  }) : _consultarResumen = consultarResumen,
       _obtenerNotificaciones = obtenerNotificaciones,
       _crearTemporizador = crearTemporizador ?? Timer.periodic;

  final ConsultarResumenNotificacionesUseCase _consultarResumen;
  final ObtenerNotificacionesUseCase _obtenerNotificaciones;
  final CrearTemporizadorPeriodico _crearTemporizador;
  final Duration intervalo;

  ResumenNotificaciones _resumen = ResumenNotificaciones.vacio;
  ResumenNotificaciones get resumen => _resumen;

  /// Se llama con los avisos que no se habían mostrado todavía.
  /// En la primera consulta recibe todos los pendientes de golpe.
  void Function(List<Notificacion> nuevos, {required bool alIniciar})?
  alLlegarAvisos;

  final Set<int> _mostrados = {};
  Timer? _temporizador;
  bool _iniciado = false;
  bool _primeraConsulta = true;
  bool _consultando = false;
  bool _descartado = false;

  void iniciar() {
    if (_iniciado) return;
    _iniciado = true;
    WidgetsBinding.instance.addObserver(this);
    _reanudar();
  }

  /// Consulta ya (por ejemplo, después de leer un aviso).
  Future<void> actualizar() async {
    if (_consultando || _descartado) return;
    _consultando = true;
    try {
      final resumen = await _consultarResumen();
      if (_descartado) return;
      _resumen = resumen;
      notifyListeners();
      if (resumen.hayPendientes) await _buscarNuevos();
      _primeraConsulta = false;
    } catch (_) {
      // Sin red o sesión caducada: se conserva el último resumen y se
      // reintenta en la siguiente consulta.
    } finally {
      _consultando = false;
    }
  }

  Future<void> _buscarNuevos() async {
    final pagina = await _obtenerNotificaciones(limite: 10, soloNoLeidas: true);
    if (_descartado) return;
    final nuevos = pagina.notificaciones
        .where((n) => _mostrados.add(n.id))
        .toList();
    if (nuevos.isNotEmpty) {
      alLlegarAvisos?.call(nuevos, alIniciar: _primeraConsulta);
    }
  }

  void _reanudar() {
    _temporizador?.cancel();
    unawaited(actualizar());
    _temporizador = _crearTemporizador(intervalo, (_) => actualizar());
  }

  void _pausar() {
    _temporizador?.cancel();
    _temporizador = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_iniciado || _descartado) return;
    if (state == AppLifecycleState.resumed) {
      _reanudar();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _pausar();
    }
  }

  @override
  void dispose() {
    _descartado = true;
    _pausar();
    if (_iniciado) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
