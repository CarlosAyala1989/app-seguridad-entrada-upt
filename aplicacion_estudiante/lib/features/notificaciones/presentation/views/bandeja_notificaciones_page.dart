import 'package:flutter/material.dart';

import '../../../../shared/l10n/app_strings.dart';
import '../../domain/entities/notificacion.dart';
import '../states/bandeja_state.dart';
import '../viewmodels/bandeja_view_model.dart';
import '../widgets/notificacion_tile.dart';

/// Bandeja personal de avisos (US-20).
class BandejaNotificacionesPage extends StatefulWidget {
  const BandejaNotificacionesPage({
    super.key,
    required this.viewModel,
    required this.abrirDetalle,
  });

  final BandejaViewModel viewModel;

  /// Abre el detalle y devuelve el aviso actualizado (ya leído) al volver.
  final Future<Notificacion?> Function(BuildContext, Notificacion)
  abrirDetalle;

  @override
  State<BandejaNotificacionesPage> createState() =>
      _BandejaNotificacionesPageState();
}

class _BandejaNotificacionesPageState extends State<BandejaNotificacionesPage> {
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

  Future<void> _filtrar(TipoNotificacion? filtro) async {
    final carga = widget.viewModel.cambiarFiltro(filtro);
    setState(() {}); // marca el chip elegido mientras carga
    await carga;
  }

  Future<void> _abrir(Notificacion notificacion) async {
    final actualizada = await widget.abrirDetalle(context, notificacion);
    if (actualizada != null) widget.viewModel.actualizar(actualizada);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.notificationsTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text(AppStrings.historyAll),
                    selected: widget.viewModel.filtro == null,
                    onSelected: (_) => _filtrar(null),
                  ),
                  ChoiceChip(
                    label: const Text(AppStrings.notificationsDenials),
                    selected:
                        widget.viewModel.filtro ==
                        TipoNotificacion.denegacionAcceso,
                    onSelected: (_) =>
                        _filtrar(TipoNotificacion.denegacionAcceso),
                  ),
                  ChoiceChip(
                    avatar: const Icon(Icons.gpp_maybe, size: 18),
                    label: const Text(AppStrings.notificationsAlerts),
                    selected:
                        widget.viewModel.filtro ==
                        TipoNotificacion.intentoSospechoso,
                    onSelected: (_) =>
                        _filtrar(TipoNotificacion.intentoSospechoso),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<BandejaState>(
          stream: widget.viewModel.states,
          initialData: widget.viewModel.currentState,
          builder: (context, snapshot) {
            final estado = snapshot.data ?? const BandejaCargando();
            return switch (estado) {
              BandejaCargando() => const Center(
                child: CircularProgressIndicator(),
              ),
              BandejaVacia() => _Mensaje(
                icono: Icons.notifications_none,
                texto: AppStrings.notificationsEmpty,
                onReintentar: widget.viewModel.cargar,
              ),
              BandejaError(:final message) => _Mensaje(
                icono: Icons.error_outline,
                texto: message,
                onReintentar: widget.viewModel.cargar,
              ),
              BandejaDatos datos => RefreshIndicator(
                onRefresh: widget.viewModel.cargar,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: datos.notificaciones.length + 1,
                  itemBuilder: (context, i) {
                    if (i < datos.notificaciones.length) {
                      final n = datos.notificaciones[i];
                      return NotificacionTile(
                        notificacion: n,
                        onTap: () => _abrir(n),
                      );
                    }
                    return Column(
                      children: [
                        if (datos.mensaje != null)
                          Text(datos.mensaje!, textAlign: TextAlign.center),
                        if (datos.cargandoMas)
                          const CircularProgressIndicator()
                        else if (datos.hayMas)
                          OutlinedButton(
                            onPressed: () => widget.viewModel.cargarMas(),
                            child: const Text(AppStrings.historyMore),
                          ),
                      ],
                    );
                  },
                ),
              ),
            };
          },
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
    required this.onReintentar,
  });

  final IconData icono;
  final String texto;
  final Future<void> Function() onReintentar;

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
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () => onReintentar(),
              child: const Text(AppStrings.reload),
            ),
          ],
        ),
      ),
    );
  }
}
