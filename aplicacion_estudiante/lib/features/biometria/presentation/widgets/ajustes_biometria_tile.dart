import 'package:flutter/material.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/l10n/app_strings.dart';

/// Interruptor "Desbloquear con huella o rostro". No se muestra si el
/// teléfono no tiene biometría (por ejemplo, en el navegador).
class AjustesBiometriaTile extends StatefulWidget {
  const AjustesBiometriaTile({
    super.key,
    required this.estaDisponible,
    required this.estaActivada,
    required this.activar,
    required this.desactivar,
  });

  final Future<bool> Function() estaDisponible;
  final Future<bool> Function() estaActivada;
  final Future<bool> Function() activar;
  final Future<void> Function() desactivar;

  @override
  State<AjustesBiometriaTile> createState() => _AjustesBiometriaTileState();
}

class _AjustesBiometriaTileState extends State<AjustesBiometriaTile> {
  bool _disponible = false;
  bool _activada = false;
  bool _cambiando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final disponible = await widget.estaDisponible();
    final activada = disponible && await widget.estaActivada();
    if (!mounted) return;
    setState(() {
      _disponible = disponible;
      _activada = activada;
    });
  }

  Future<void> _cambiar(bool activar) async {
    setState(() => _cambiando = true);
    var activada = _activada;
    String? aviso;
    try {
      if (activar) {
        activada = await widget.activar();
      } else {
        await widget.desactivar();
        activada = false;
      }
    } on Failure catch (f) {
      aviso = f.message;
    } catch (_) {
      aviso = AppStrings.biometricsError;
    }
    if (!mounted) return;
    setState(() {
      _activada = activada;
      _cambiando = false;
    });
    if (aviso != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(aviso)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_disponible) return const SizedBox.shrink();
    return Card(
      child: SwitchListTile(
        secondary: const Icon(Icons.fingerprint),
        title: const Text(AppStrings.biometricsTitle),
        subtitle: const Text(AppStrings.biometricsSubtitle),
        value: _activada,
        onChanged: _cambiando ? null : _cambiar,
      ),
    );
  }
}
