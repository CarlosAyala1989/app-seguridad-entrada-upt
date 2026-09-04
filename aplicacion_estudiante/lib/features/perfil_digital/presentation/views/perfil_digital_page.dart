import 'package:flutter/material.dart';

import '../../../../shared/l10n/app_strings.dart';
import '../../domain/entities/perfil_digital.dart';
import '../states/perfil_digital_state.dart';
import '../viewmodels/perfil_digital_view_model.dart';

class PerfilDigitalPage extends StatefulWidget {
  const PerfilDigitalPage({super.key, required this.viewModel});

  final PerfilDigitalViewModel viewModel;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profileTitle)),
      body: SafeArea(
        child: StreamBuilder<PerfilDigitalState>(
          stream: widget.viewModel.states,
          initialData: widget.viewModel.currentState,
          builder: (context, snapshot) => _StateBody(
            state: snapshot.data ?? const PerfilDigitalLoading(),
            onReload: widget.viewModel.cargar,
          ),
        ),
      ),
    );
  }
}

class _StateBody extends StatelessWidget {
  const _StateBody({required this.state, required this.onReload});

  final PerfilDigitalState state;
  final Future<void> Function() onReload;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      PerfilDigitalLoading() => Center(
          child: Semantics(
            label: AppStrings.loadingProfile,
            child: const CircularProgressIndicator(),
          ),
        ),
      PerfilDigitalData(:final perfil) => _ProfileCard(perfil: perfil),
      PerfilDigitalEmpty() => _EmptyState(onRetry: onReload),
      PerfilDigitalError(:final message, :final retry) => _ErrorState(
          message: message,
          onRetry: retry,
        ),
    };
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.perfil});

  final PerfilDigital perfil;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        CircleAvatar(
          radius: 44,
          child: Text(
            perfil.nombreCompleto.isEmpty ? '?' : perfil.nombreCompleto[0],
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          perfil.nombreCompleto,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        _ProfileRow(
          label: AppStrings.code,
          value: perfil.codigoInstitucional,
        ),
        _ProfileRow(
          label: AppStrings.email,
          value: perfil.correoInstitucional,
        ),
        _ProfileRow(label: AppStrings.role, value: perfil.rol),
        _ProfileRow(label: AppStrings.school, value: perfil.escuela),
        _ProfileRow(
          label: AppStrings.identity,
          value: perfil.estadoVerificacion,
        ),
        _ProfileRow(label: AppStrings.access, value: perfil.estadoAcceso),
      ],
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
      child: ListTile(
        title: Text(label),
        subtitle: Text(value),
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
