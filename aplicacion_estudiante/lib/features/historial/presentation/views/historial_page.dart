import 'package:flutter/material.dart';

import '../../../../shared/l10n/app_strings.dart';
import '../../domain/entities/registro_historial.dart';
import '../states/historial_state.dart';
import '../viewmodels/historial_view_model.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key, required this.viewModel});

  final HistorialViewModel viewModel;

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
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

  Future<void> _filtrar(ResultadoIngreso? filtro) async {
    final carga = widget.viewModel.cambiarFiltro(filtro);
    setState(() {}); // marca el chip elegido mientras carga
    await carga;
  }

  @override
  Widget build(BuildContext context) {
    final filtro = widget.viewModel.filtro;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.historyTitle)),
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
                    selected: filtro == null,
                    onSelected: (_) => _filtrar(null),
                  ),
                  ChoiceChip(
                    label: const Text(AppStrings.historyEntries),
                    selected: filtro == ResultadoIngreso.autorizado,
                    onSelected: (_) => _filtrar(ResultadoIngreso.autorizado),
                  ),
                  ChoiceChip(
                    label: const Text(AppStrings.historyRejections),
                    selected: filtro == ResultadoIngreso.denegado,
                    onSelected: (_) => _filtrar(ResultadoIngreso.denegado),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<HistorialState>(
                stream: widget.viewModel.states,
                initialData: widget.viewModel.currentState,
                builder: (context, snapshot) {
                  final estado = snapshot.data ?? const HistorialCargando();
                  return switch (estado) {
                    HistorialCargando() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    HistorialVacio() => _Mensaje(
                      icono: Icons.history,
                      texto: AppStrings.historyEmpty,
                      onReintentar: widget.viewModel.cargar,
                    ),
                    HistorialError(:final message) => _Mensaje(
                      icono: Icons.error_outline,
                      texto: message,
                      onReintentar: widget.viewModel.cargar,
                    ),
                    HistorialDatos datos => _Lista(
                      estado: datos,
                      onCargarMas: widget.viewModel.cargarMas,
                      onActualizar: widget.viewModel.cargar,
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

class _Lista extends StatelessWidget {
  const _Lista({
    required this.estado,
    required this.onCargarMas,
    required this.onActualizar,
  });

  final HistorialDatos estado;
  final Future<void> Function() onCargarMas;
  final Future<void> Function() onActualizar;

  @override
  Widget build(BuildContext context) {
    final registros = estado.registros;
    return RefreshIndicator(
      onRefresh: onActualizar,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: registros.length + 1,
        itemBuilder: (context, i) {
          if (i < registros.length) return RegistroTile(registro: registros[i]);
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: [
                if (estado.mensaje != null)
                  Text(estado.mensaje!, textAlign: TextAlign.center),
                if (estado.cargandoMas)
                  const CircularProgressIndicator()
                else if (estado.hayMas)
                  OutlinedButton(
                    onPressed: () => onCargarMas(),
                    child: const Text(AppStrings.historyMore),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Una fila del historial: resultado, motivo, puerta y fecha local.
class RegistroTile extends StatelessWidget {
  const RegistroTile({super.key, required this.registro});

  final RegistroHistorial registro;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final ok = registro.esAutorizado;
    return Card(
      child: ListTile(
        leading: Icon(
          ok ? Icons.check_circle : Icons.cancel,
          color: ok ? esquema.primary : esquema.error,
        ),
        title: Text(ok ? AppStrings.historyAuthorized : AppStrings.historyDenied),
        subtitle: Text(
          '${registro.puntoAccesoNombre} · ${fechaLocal(registro.registradoEn)}'
          '${ok ? '' : '\n${registro.motivoLegible}'}',
        ),
        isThreeLine: !ok,
      ),
    );
  }

  /// dd/mm/aaaa hh:mm en la hora del teléfono (la API envía UTC).
  static String fechaLocal(DateTime fecha) {
    final l = fecha.toLocal();
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(l.day)}/${dos(l.month)}/${l.year} '
        '${dos(l.hour)}:${dos(l.minute)}';
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
