import 'package:flutter/material.dart';

import '../../../../shared/l10n/app_strings.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/perfil_digital.dart';
import '../states/perfil_digital_state.dart';
import '../viewmodels/perfil_digital_view_model.dart';
import '../widgets/carne_digital_card.dart';

class PerfilDigitalPage extends StatefulWidget {
  const PerfilDigitalPage({
    super.key,
    required this.viewModel,
    this.onCerrarSesion,
    this.onVerCodigoQr,
    this.onVerAvisoPrivacidad,
    this.onVerHistorial,
    this.ajustes,
    this.accionExtra,
    this.encabezado,
    this.onVerQrSinConexion,
    this.onGuardarSinConexion,
  });

  final PerfilDigitalViewModel viewModel;

  /// Cierra la sesión; si es `null` no se muestra el botón.
  final Future<void> Function()? onCerrarSesion;

  /// Abre la pantalla del código QR; si es `null` no se muestra el botón.
  final VoidCallback? onVerCodigoQr;

  /// Abre el aviso de privacidad; si es `null` no se muestra el botón.
  final VoidCallback? onVerAvisoPrivacidad;

  /// Abre el historial personal de ingresos (US-14).
  final VoidCallback? onVerHistorial;

  /// Ajustes opcionales al final de la identidad (p. ej. biometría).
  final Widget? ajustes;

  /// Acción adicional en la barra superior (p. ej. la campana de avisos).
  final Widget? accionExtra;

  /// Se muestra encima del contenido (p. ej. una alerta de seguridad).
  final Widget? encabezado;

  /// Abre el QR sin conexión cuando no se pudo cargar la identidad (por
  /// ejemplo, sin internet). Si es `null` no se muestra el botón.
  final VoidCallback? onVerQrSinConexion;
  final Future<bool> Function()? onGuardarSinConexion;

  @override
  State<PerfilDigitalPage> createState() => _PerfilDigitalPageState();
}

class _PerfilDigitalPageState extends State<PerfilDigitalPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(widget.viewModel.cargar);
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  bool _cerrando = false;
  bool _guardando = false;

  Future<void> _guardarSinConexion() async {
    setState(() => _guardando = true);
    var guardado = false;
    try {
      guardado = await widget.onGuardarSinConexion!();
    } catch (_) {
      guardado = false;
    }
    if (!mounted) return;
    setState(() => _guardando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          guardado
              ? 'QR preparado para usar sin conexión.'
              : 'No se pudo preparar el QR sin conexión. Inténtalo con internet.',
        ),
      ),
    );
  }

  Future<void> _confirmarCierre() async {
    if (_cerrando) return;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.logoutConfirmTitle),
        content: const Text(AppStrings.logoutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;
    setState(() => _cerrando = true);
    await widget.onCerrarSesion!();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profileTitle),
        centerTitle: false,
        actions: [
          if (widget.accionExtra != null) widget.accionExtra!,
          if (widget.onVerAvisoPrivacidad != null)
            IconButton(
              icon: const Icon(Icons.privacy_tip_outlined),
              tooltip: AppStrings.privacyTitle,
              onPressed: widget.onVerAvisoPrivacidad,
            ),
          if (widget.onCerrarSesion != null)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: AppStrings.logout,
              onPressed: _cerrando ? null : _confirmarCierre,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (widget.encabezado != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: widget.encabezado,
              ),
            Expanded(
              child: StreamBuilder<PerfilDigitalState>(
                stream: widget.viewModel.states,
                initialData: widget.viewModel.currentState,
                builder: (context, snapshot) => _StateBody(
                  state: snapshot.data ?? const PerfilDigitalLoading(),
                  onReload: widget.viewModel.cargar,
                  onVerCodigoQr: widget.onVerCodigoQr,
                  onVerHistorial: widget.onVerHistorial,
                  ajustes: widget.ajustes,
                  onVerQrSinConexion: widget.onVerQrSinConexion,
                  onGuardarSinConexion:
                      widget.onGuardarSinConexion == null || _guardando
                      ? null
                      : _guardarSinConexion,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateBody extends StatelessWidget {
  const _StateBody({
    required this.state,
    required this.onReload,
    this.onVerCodigoQr,
    this.onVerHistorial,
    this.ajustes,
    this.onVerQrSinConexion,
    this.onGuardarSinConexion,
  });

  final PerfilDigitalState state;
  final Future<void> Function() onReload;
  final VoidCallback? onVerCodigoQr;
  final VoidCallback? onVerHistorial;
  final Widget? ajustes;
  final VoidCallback? onVerQrSinConexion;
  final VoidCallback? onGuardarSinConexion;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      PerfilDigitalLoading() => Center(
        child: Semantics(
          label: AppStrings.loadingProfile,
          child: const CircularProgressIndicator(),
        ),
      ),
      PerfilDigitalData(:final perfil) => _ProfileCard(
        perfil: perfil,
        onVerCodigoQr: onVerCodigoQr,
        onVerHistorial: onVerHistorial,
        ajustes: ajustes,
        onGuardarSinConexion: onGuardarSinConexion,
      ),
      PerfilDigitalEmpty() => _EmptyState(onRetry: onReload),
      PerfilDigitalError(:final message, :final retry) => _ErrorState(
        message: message,
        onRetry: retry,
        onVerQrSinConexion: onVerQrSinConexion,
      ),
    };
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.perfil,
    this.onVerCodigoQr,
    this.onVerHistorial,
    this.ajustes,
    this.onGuardarSinConexion,
  });

  final PerfilDigital perfil;
  final VoidCallback? onVerCodigoQr;
  final VoidCallback? onVerHistorial;
  final Widget? ajustes;
  final VoidCallback? onGuardarSinConexion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            CarneDigitalCard(perfil: perfil),
            const SizedBox(height: 16),
            EstadoIngresoCard(perfil: perfil),
            if (onVerCodigoQr != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: perfil.puedeSolicitarCodigoQr ? onVerCodigoQr : null,
                icon: const Icon(Icons.qr_code_2),
                label: const Text(AppStrings.showQr),
              ),
              if (!perfil.puedeSolicitarCodigoQr)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    AppStrings.qrNotAvailable,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textoSecundario,
                    ),
                  ),
                ),
            ],
            if (onVerHistorial != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onVerHistorial,
                icon: const Icon(Icons.history),
                label: const Text(AppStrings.historyTitle),
              ),
            ],
            if (onGuardarSinConexion != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onGuardarSinConexion,
                icon: const Icon(Icons.offline_pin_outlined),
                label: const Text('Guardar QR sin conexión'),
              ),
            ],
            if (ajustes != null) ...[const SizedBox(height: 20), ajustes!],
          ],
        ),
      ),
    );
  }
}

/// Responde de un vistazo si hoy se puede ingresar (US-07).
class EstadoIngresoCard extends StatelessWidget {
  const EstadoIngresoCard({super.key, required this.perfil});

  final PerfilDigital perfil;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final puede = perfil.permiteIngreso;
    final colorPrincipal = puede
        ? AppColors.verdeAutorizado
        : AppColors.rojoError;
    final colorFondo = puede ? AppColors.verdeFondo : AppColors.rojoFondo;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: puede ? AppColors.bordeSuave : AppColors.rojoError,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorFondo,
              shape: BoxShape.circle,
            ),
            child: Icon(
              puede ? Icons.check_circle : Icons.block,
              color: colorPrincipal,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  puede ? AppStrings.canEnter : AppStrings.cannotEnter,
                  style: textos.titleMedium?.copyWith(color: colorPrincipal),
                ),
                const SizedBox(height: 2),
                Text(
                  puede
                      ? AppStrings.canEnterDetail
                      : '${perfil.motivoSinIngreso} ${AppStrings.contactSupport}',
                  style: textos.bodySmall?.copyWith(
                    color: AppColors.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.badge_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              AppStrings.emptyProfile,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.emptyProfileHelp,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () => onRetry(),
              child: const Text(AppStrings.reload),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
    this.onVerQrSinConexion,
  });

  final String message;
  final Future<void> Function() onRetry;
  final VoidCallback? onVerQrSinConexion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => onRetry(),
              icon: const Icon(Icons.refresh),
              label: const Text(AppStrings.retry),
            ),
            if (onVerQrSinConexion != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onVerQrSinConexion,
                icon: const Icon(Icons.qr_code_2),
                label: const Text(AppStrings.showQrOffline),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
