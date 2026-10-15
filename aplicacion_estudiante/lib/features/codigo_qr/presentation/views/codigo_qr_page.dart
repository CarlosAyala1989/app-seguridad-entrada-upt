import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../shared/l10n/app_strings.dart';
import '../../../ubicacion/presentation/widgets/explicacion_ubicacion_dialog.dart';
import '../states/codigo_qr_state.dart';
import '../viewmodels/codigo_qr_view_model.dart';

class CodigoQrPage extends StatefulWidget {
  const CodigoQrPage({super.key, required this.viewModel});

  final CodigoQrViewModel viewModel;

  @override
  State<CodigoQrPage> createState() => _CodigoQrPageState();
}

class _CodigoQrPageState extends State<CodigoQrPage> {
  bool _ubicacionExplicada = false;

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<void> _generar() async {
    if (!_ubicacionExplicada) {
      final continuar = await confirmarUsoUbicacion(context);
      if (!continuar || !mounted) return;
      _ubicacionExplicada = true;
    }
    await widget.viewModel.generar();
  }

  Future<void> _revocar() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.revokeQrTitle),
        content: const Text(AppStrings.revokeQrBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.revokeQr),
          ),
        ],
      ),
    );
    if (confirmado != true) return;
    final anulado = await widget.viewModel.revocar();
    if (!mounted) return;
    if (!anulado) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppStrings.qrRevoked)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.qrTitle)),
      body: SafeArea(
        child: StreamBuilder<CodigoQrState>(
          stream: widget.viewModel.states,
          initialData: widget.viewModel.currentState,
          builder: (context, snapshot) {
            final estado = snapshot.data ?? const CodigoQrInicial();
            return switch (estado) {
              CodigoQrInicial() => _Mensaje(
                icono: Icons.qr_code_2,
                texto: AppStrings.qrIntro,
                accion: AppStrings.generateQr,
                alPulsar: _generar,
              ),
              CodigoQrCargando() => const _Cargando(),
              CodigoQrVisible visible => _CodigoVisible(
                estado: visible,
                alRevocar: _revocar,
              ),
              CodigoQrError(:final message) => _Mensaje(
                icono: Icons.error_outline,
                texto: message,
                accion: AppStrings.retry,
                alPulsar: _generar,
              ),
            };
          },
        ),
      ),
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(AppStrings.generatingQr, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Mensaje extends StatelessWidget {
  const _Mensaje({
    required this.icono,
    required this.texto,
    required this.accion,
    required this.alPulsar,
  });

  final IconData icono;
  final String texto;
  final String accion;
  final Future<void> Function() alPulsar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 64),
            const SizedBox(height: 16),
            Text(texto, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => alPulsar(),
              icon: const Icon(Icons.qr_code),
              label: Text(accion),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodigoVisible extends StatelessWidget {
  const _CodigoVisible({required this.estado, required this.alRevocar});

  final CodigoQrVisible estado;
  final Future<void> Function() alRevocar;

  @override
  Widget build(BuildContext context) {
    final codigo = estado.codigo;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: QrImageView(
              data: codigo.contenido,
              size: 240,
              backgroundColor: Colors.white,
              semanticsLabel: AppStrings.qrTitle,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${AppStrings.qrValidUntil} ${_hora(codigo.expiraEn)}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          codigo.unSoloUso
              ? '${AppStrings.qrAutoRenew} ${AppStrings.qrOneUse}'
              : AppStrings.qrAutoRenew,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.place_outlined),
            title: Text(codigo.puntoAccesoNombre),
          ),
        ),
        if (estado.mensaje != null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.warning_amber_outlined),
              title: Text(estado.mensaje!),
            ),
          ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: estado.revocando ? null : () => alRevocar(),
          icon: const Icon(Icons.block),
          label: const Text(AppStrings.revokeQr),
        ),
      ],
    );
  }

  static String _hora(DateTime fecha) {
    final local = fecha.toLocal();
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(local.hour)}:${dos(local.minute)}:${dos(local.second)}';
  }
}
