import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../shared/l10n/app_strings.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../ubicacion/presentation/widgets/explicacion_ubicacion_dialog.dart';
import '../states/codigo_qr_state.dart';
import '../viewmodels/codigo_qr_view_model.dart';

class CodigoQrPage extends StatefulWidget {
  const CodigoQrPage({
    super.key,
    required this.viewModel,
    this.onVerAvisoPrivacidad,
  });

  final CodigoQrViewModel viewModel;

  /// Abre el aviso de privacidad desde la explicación de la ubicación.
  final VoidCallback? onVerAvisoPrivacidad;

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
      final continuar = await confirmarUsoUbicacion(
        context,
        onVerAvisoPrivacidad: widget.onVerAvisoPrivacidad,
      );
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
                esError: true,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _IconoCircular(icono: Icons.my_location),
            const SizedBox(height: 24),
            const SizedBox(
              width: 180,
              child: LinearProgressIndicator(minHeight: 4),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.generatingQr,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textoSecundario,
              ),
            ),
          ],
        ),
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
    this.esError = false,
  });

  final IconData icono;
  final String texto;
  final String accion;
  final Future<void> Function() alPulsar;
  final bool esError;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: _IconoCircular(icono: icono, esError: esError)),
              const SizedBox(height: 20),
              Text(
                esError ? AppStrings.qrErrorTitle : AppStrings.qrPassTitle,
                textAlign: TextAlign.center,
                style: textos.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                texto,
                textAlign: TextAlign.center,
                style: textos.bodyLarge?.copyWith(
                  color: AppColors.textoSecundario,
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => alPulsar(),
                icon: Icon(esError ? Icons.refresh : Icons.qr_code),
                label: Text(accion),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconoCircular extends StatelessWidget {
  const _IconoCircular({required this.icono, this.esError = false});

  final IconData icono;
  final bool esError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: esError ? AppColors.rojoFondo : AppColors.superficie,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icono,
        size: 48,
        color: esError ? AppColors.rojoError : AppColors.azulUpt,
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
    final textos = Theme.of(context).textTheme;
    final codigo = estado.codigo;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              AppStrings.qrPassTitle,
              textAlign: TextAlign.center,
              style: textos.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.qrPassSubtitle,
              textAlign: TextAlign.center,
              style: textos.bodyMedium?.copyWith(
                color: AppColors.textoSecundario,
              ),
            ),
            const SizedBox(height: 16),
            // El QR va siempre sobre blanco y con margen para que el lector
            // de la puerta lo detecte bien.
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.azulUpt, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A001244),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: codigo.contenido,
                  size: 240,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.azulProfundo,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.azulProfundo,
                  ),
                  semanticsLabel: AppStrings.qrTitle,
                ),
              ),
            ),
            const SizedBox(height: 20),
            CuentaRegresivaQr(
              segundosRestantes: estado.segundosRestantes,
              duracionSegundos: codigo.duracionSegundos,
            ),
            const SizedBox(height: 16),
            _TarjetaQr(
              children: [
                _FilaDato(
                  icono: Icons.schedule,
                  titulo: '${AppStrings.qrValidUntil} ${_hora(codigo.expiraEn)}',
                ),
                const Divider(height: 20),
                _FilaDato(
                  icono: Icons.autorenew,
                  titulo: codigo.unSoloUso
                      ? '${AppStrings.qrAutoRenew} ${AppStrings.qrOneUse}'
                      : AppStrings.qrAutoRenew,
                ),
                const Divider(height: 20),
                _FilaDato(
                  icono: Icons.door_front_door_outlined,
                  etiqueta: AppStrings.qrAccessPoint,
                  titulo: codigo.puntoAccesoNombre,
                ),
              ],
            ),
            if (estado.mensaje != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.doradoClaro,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_outlined,
                      color: AppColors.dorado,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(estado.mensaje!)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: estado.revocando ? null : () => alRevocar(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.rojoError,
                side: const BorderSide(color: AppColors.rojoFondo),
              ),
              icon: const Icon(Icons.block),
              label: const Text(AppStrings.revokeQr),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.revokeQrHelp,
              textAlign: TextAlign.center,
              style: textos.bodySmall?.copyWith(
                color: AppColors.textoSecundario,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _hora(DateTime fecha) {
    final local = fecha.toLocal();
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(local.hour)}:${dos(local.minute)}:${dos(local.second)}';
  }
}

class _TarjetaQr extends StatelessWidget {
  const _TarjetaQr({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.bordeSuave),
      ),
      child: Column(children: children),
    );
  }
}

class _FilaDato extends StatelessWidget {
  const _FilaDato({required this.icono, required this.titulo, this.etiqueta});

  final IconData icono;
  final String titulo;
  final String? etiqueta;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.superficieBaja,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icono, size: 20, color: AppColors.azulUpt),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (etiqueta != null)
                Text(
                  etiqueta!,
                  style: textos.labelSmall?.copyWith(
                    color: AppColors.textoSecundario,
                  ),
                ),
              Text(titulo, style: textos.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

/// Cuánto le queda al código (US-07). En los últimos 10 segundos se pinta en
/// el color de error para avisar de que está por renovarse.
class CuentaRegresivaQr extends StatelessWidget {
  const CuentaRegresivaQr({
    super.key,
    required this.segundosRestantes,
    required this.duracionSegundos,
  });

  final int segundosRestantes;
  final int duracionSegundos;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final urgente = segundosRestantes <= 10;
    final color = urgente ? esquema.error : esquema.primary;
    final progreso = duracionSegundos <= 0
        ? 0.0
        : (segundosRestantes / duracionSegundos).clamp(0.0, 1.0);
    return Semantics(
      label: '${AppStrings.timeLeft}: $segundosRestantes segundos',
      child: Column(
        children: [
          Text(
            '$segundosRestantes ${AppStrings.secondsShort}',
            style: textos.displaySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            AppStrings.timeLeft,
            style: textos.labelMedium?.copyWith(
              color: AppColors.textoSecundario,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progreso,
              color: color,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
