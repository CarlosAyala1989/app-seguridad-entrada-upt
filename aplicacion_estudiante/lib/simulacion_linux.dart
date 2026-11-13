import 'dart:async';

import 'package:flutter/material.dart';

import 'features/codigo_qr/domain/entities/vinculacion_qr_offline.dart';
import 'features/codigo_qr/presentation/states/codigo_qr_state.dart';
import 'features/codigo_qr/presentation/views/codigo_qr_page.dart';
import 'shared/l10n/app_strings.dart';

/// Demostración local: el QR no está vinculado a una cuenta ni autoriza ingreso.
class SimulacionLinux extends StatelessWidget {
  const SimulacionLinux({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Identidad digital UPT')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.error_outline, size: 56),
              const SizedBox(height: 24),
              const Text(AppStrings.networkError, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const _QrSimulado()),
                ),
                icon: const Icon(Icons.qr_code),
                label: const Text('Mostrar mi QR sin conexión'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _QrSimulado extends StatefulWidget {
  const _QrSimulado();
  @override
  State<_QrSimulado> createState() => _QrSimuladoState();
}

class _QrSimuladoState extends State<_QrSimulado> {
  // Clave de prueba pública; este código no puede autorizar el ingreso.
  static const _vinculacion = VinculacionQrOffline(
    usuarioId: 1,
    dispositivoId: 1,
    secreto: 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
    periodoSegundos: 15,
    desfaseRelojMs: 0,
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ahora = DateTime.now();
    final codigo = _vinculacion.generar(ahora);
    return Scaffold(
      appBar: AppBar(title: const Text('Mi código QR')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('QR de prueba: no autoriza el ingreso.'),
          ),
          Expanded(
            child: CodigoOfflineVisible(
              estado: CodigoQrOfflineVisible(
                codigo: codigo,
                segundosRestantes: codigo.segundosRestantes(ahora),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
