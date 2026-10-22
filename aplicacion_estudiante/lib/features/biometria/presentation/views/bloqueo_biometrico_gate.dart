import 'package:flutter/material.dart';

import '../../../../shared/l10n/app_strings.dart';

enum _EstadoBloqueo { comprobando, bloqueado, libre }

/// Cubre toda la app con una pantalla de bloqueo cuando hace falta (US-22):
/// al abrirla con una sesión guardada y al volver tras [tiempoGracia] fuera.
///
/// La app sigue viva debajo (no pierde lo que había en pantalla), pero no se
/// ve ni se puede tocar hasta desbloquear.
class BloqueoBiometricoGate extends StatefulWidget {
  const BloqueoBiometricoGate({
    super.key,
    required this.child,
    required this.debeBloquear,
    required this.desbloquear,
    required this.onCerrarSesion,
    this.tiempoGracia = const Duration(seconds: 30),
    this.ahora = DateTime.now,
  });

  final Widget child;
  final Future<bool> Function() debeBloquear;
  final Future<bool> Function() desbloquear;

  /// Salida si la biometría no funciona: vuelve al login institucional.
  final Future<void> Function() onCerrarSesion;
  final Duration tiempoGracia;
  final DateTime Function() ahora;

  @override
  State<BloqueoBiometricoGate> createState() => _BloqueoBiometricoGateState();
}

class _BloqueoBiometricoGateState extends State<BloqueoBiometricoGate>
    with WidgetsBindingObserver {
  _EstadoBloqueo _estado = _EstadoBloqueo.comprobando;
  DateTime? _salioEn;
  bool _autenticando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _comprobar();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _salioEn ??= widget.ahora();
    } else if (state == AppLifecycleState.resumed) {
      final salioEn = _salioEn;
      _salioEn = null;
      if (salioEn != null &&
          widget.ahora().difference(salioEn) >= widget.tiempoGracia &&
          _estado == _EstadoBloqueo.libre) {
        _comprobar();
      }
    }
  }

  Future<void> _comprobar() async {
    final bloquear = await widget.debeBloquear();
    if (!mounted) return;
    setState(
      () => _estado = bloquear ? _EstadoBloqueo.bloqueado : _EstadoBloqueo.libre,
    );
    if (bloquear) await _desbloquear();
  }

  Future<void> _desbloquear() async {
    if (_autenticando) return;
    _autenticando = true;
    final ok = await widget.desbloquear();
    _autenticando = false;
    if (!mounted || !ok) return;
    setState(() => _estado = _EstadoBloqueo.libre);
  }

  Future<void> _cerrarSesion() async {
    await widget.onCerrarSesion();
    if (!mounted) return;
    setState(() => _estado = _EstadoBloqueo.libre);
  }

  @override
  Widget build(BuildContext context) {
    final libre = _estado == _EstadoBloqueo.libre;
    return Stack(
      children: [
        Offstage(offstage: !libre, child: widget.child),
        if (!libre)
          PantallaBloqueo(
            comprobando: _estado == _EstadoBloqueo.comprobando,
            onDesbloquear: _desbloquear,
            onCerrarSesion: _cerrarSesion,
          ),
      ],
    );
  }
}

class PantallaBloqueo extends StatelessWidget {
  const PantallaBloqueo({
    super.key,
    required this.comprobando,
    required this.onDesbloquear,
    required this.onCerrarSesion,
  });

  final bool comprobando;
  final Future<void> Function() onDesbloquear;
  final Future<void> Function() onCerrarSesion;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: comprobando
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.fingerprint, size: 72),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.lockedTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        AppStrings.lockedBody,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => onDesbloquear(),
                        icon: const Icon(Icons.lock_open),
                        label: const Text(AppStrings.unlock),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => onCerrarSesion(),
                        child: const Text(AppStrings.logout),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
