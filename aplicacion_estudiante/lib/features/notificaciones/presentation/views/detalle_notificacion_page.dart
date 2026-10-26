import 'package:flutter/material.dart';

import '../../../../shared/l10n/app_strings.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/notificacion.dart';
import '../widgets/notificacion_tile.dart';

/// Detalle de un aviso: causa general, puerta, momento y canal de soporte.
///
/// La lectura se confirma después de mostrarlo, como pide la API, y al
/// volver se devuelve el aviso actualizado.
class DetalleNotificacionPage extends StatefulWidget {
  const DetalleNotificacionPage({
    super.key,
    required this.notificacion,
    required this.obtenerDetalle,
    required this.marcarLeida,
  });

  /// Lo que ya se veía en la bandeja: se muestra mientras llega el detalle.
  final Notificacion notificacion;
  final Future<Notificacion> Function(int id) obtenerDetalle;
  final Future<Notificacion> Function(Notificacion) marcarLeida;

  @override
  State<DetalleNotificacionPage> createState() =>
      _DetalleNotificacionPageState();
}

class _DetalleNotificacionPageState extends State<DetalleNotificacionPage> {
  late Notificacion _notificacion = widget.notificacion;

  @override
  void initState() {
    super.initState();
    _cargarYConfirmar();
  }

  Future<void> _cargarYConfirmar() async {
    try {
      final detalle = await widget.obtenerDetalle(_notificacion.id);
      if (!mounted) return;
      setState(() => _notificacion = detalle);
      // Ya está en pantalla: ahora sí se confirma la lectura.
      final leida = await widget.marcarLeida(detalle);
      if (!mounted) return;
      setState(() => _notificacion = leida);
    } catch (_) {
      // Se sigue mostrando lo que ya había; la lectura se confirmará la
      // próxima vez que se abra.
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = _notificacion;
    final textos = Theme.of(context).textTheme;
    return PopScope<Notificacion>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_notificacion);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.notificationDetail)),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (n.esAlerta) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.rojoFondo,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppColors.rojoError),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.gpp_maybe, color: AppColors.rojoError),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.securityAlert,
                              style: textos.titleSmall?.copyWith(
                                color: AppColors.rojoTexto,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.securityAlertHelp,
                              style: textos.bodySmall?.copyWith(
                                color: AppColors.rojoTexto,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Text(n.titulo, style: textos.headlineMedium),
              const SizedBox(height: 8),
              Text(
                n.mensaje,
                style: textos.bodyLarge?.copyWith(
                  color: AppColors.textoSecundario,
                ),
              ),
              const SizedBox(height: 20),
              _Dato(
                icono: Icons.info_outline,
                titulo: AppStrings.notificationCause,
                valor: n.causaGeneral,
              ),
              _Dato(
                icono: Icons.place_outlined,
                titulo: AppStrings.notificationPlace,
                valor: n.puntoAccesoNombre,
              ),
              _Dato(
                icono: Icons.schedule,
                titulo: AppStrings.notificationWhen,
                valor: fechaHoraLocal(n.registradoEn),
              ),
              _Dato(
                icono: Icons.support_agent,
                titulo: AppStrings.notificationSupport,
                valor: n.canalSoporte,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.icono, required this.titulo, required this.valor});

  final IconData icono;
  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.bordeSuave),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Text(
                  titulo,
                  style: textos.labelMedium?.copyWith(
                    color: AppColors.textoSecundario,
                  ),
                ),
                const SizedBox(height: 2),
                Text(valor, style: textos.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
