import 'package:flutter/material.dart';

import '../../../../shared/l10n/app_strings.dart';
import '../../domain/entities/perfil_digital.dart';
import '../states/perfil_digital_state.dart';
import '../viewmodels/perfil_digital_view_model.dart';

class PerfilDigitalPage extends StatefulWidget {
  const PerfilDigitalPage({
    super.key,
    required this.viewModel,
    this.onCerrarSesion,
    this.onVerCodigoQr,
    this.onVerAvisoPrivacidad,
  });

  final PerfilDigitalViewModel viewModel;

  /// Cierra la sesión; si es `null` no se muestra el botón.
  final Future<void> Function()? onCerrarSesion;

  /// Abre la pantalla del código QR; si es `null` no se muestra el botón.
  final VoidCallback? onVerCodigoQr;

  /// Abre el aviso de privacidad; si es `null` no se muestra el botón.
  final VoidCallback? onVerAvisoPrivacidad;

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
        actions: [
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
        child: StreamBuilder<PerfilDigitalState>(
          stream: widget.viewModel.states,
          initialData: widget.viewModel.currentState,
          builder: (context, snapshot) => _StateBody(
            state: snapshot.data ?? const PerfilDigitalLoading(),
            onReload: widget.viewModel.cargar,
            onVerCodigoQr: widget.onVerCodigoQr,
          ),
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
  });

  final PerfilDigitalState state;
  final Future<void> Function() onReload;
  final VoidCallback? onVerCodigoQr;

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
      ),
      PerfilDigitalEmpty() => _EmptyState(onRetry: onReload),
      PerfilDigitalError(:final message, :final retry) => _ErrorState(
        message: message,
        onRetry: retry,
      ),
    };
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.perfil, this.onVerCodigoQr});

  final PerfilDigital perfil;
  final VoidCallback? onVerCodigoQr;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        CircleAvatar(
          radius: 48,
          backgroundImage:
              (perfil.fotoUrl != null && perfil.fotoUrl!.isNotEmpty)
              ? NetworkImage(perfil.fotoUrl!)
              : null,
          child: (perfil.fotoUrl == null || perfil.fotoUrl!.isEmpty)
              ? Text(
                  perfil.nombreCompleto.isEmpty
                      ? '?'
                      : perfil.nombreCompleto[0],
                  style: Theme.of(context).textTheme.headlineLarge,
                )
              : null,
        ),
        const SizedBox(height: 20),
        Text(
          perfil.nombreCompleto,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        _ProfileRow(label: AppStrings.code, value: perfil.codigoInstitucional),
        _ProfileRow(label: AppStrings.email, value: perfil.correoInstitucional),
        _ProfileRow(label: AppStrings.role, value: perfil.rol),
        _ProfileRow(label: AppStrings.school, value: perfil.escuela),
        _ProfileRow(
          label: AppStrings.identity,
          value: perfil.estadoVerificacion,
        ),
        _ProfileRow(label: AppStrings.access, value: perfil.estadoAcceso),
        const SizedBox(height: 16),
        EstadoIngresoCard(perfil: perfil),
        if (onVerCodigoQr != null) ...[
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: perfil.puedeSolicitarCodigoQr ? onVerCodigoQr : null,
            icon: const Icon(Icons.qr_code_2),
            label: const Text(AppStrings.showQr),
          ),
          if (!perfil.puedeSolicitarCodigoQr)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                AppStrings.qrNotAvailable,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ],
    );
  }
}

/// Responde de un vistazo si hoy se puede ingresar (US-07).
class EstadoIngresoCard extends StatelessWidget {
  const EstadoIngresoCard({super.key, required this.perfil});

  final PerfilDigital perfil;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final puede = perfil.permiteIngreso;
    return Card(
      color: puede ? esquema.primaryContainer : esquema.errorContainer,
      child: ListTile(
        leading: Icon(
          puede ? Icons.verified_user : Icons.block,
          color: puede ? esquema.onPrimaryContainer : esquema.onErrorContainer,
        ),
        title: Text(puede ? AppStrings.canEnter : AppStrings.cannotEnter),
        subtitle: puede
            ? null
            : Text('${perfil.motivoSinIngreso} ${AppStrings.contactSupport}'),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(title: Text(label), subtitle: Text(value)),
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
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

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
          ],
        ),
      ),
    );
  }
}
