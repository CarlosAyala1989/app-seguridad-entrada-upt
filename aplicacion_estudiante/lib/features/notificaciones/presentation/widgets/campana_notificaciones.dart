import 'package:flutter/material.dart';

import '../../../../shared/l10n/app_strings.dart';
import '../../domain/entities/notificacion.dart';
import '../controllers/resumen_notificaciones_controller.dart';

/// Campana de la barra superior con el número de avisos sin leer (US-20).
/// Mientras está en pantalla consulta los pendientes y muestra un aviso
/// emergente cuando llega uno nuevo.
class CampanaNotificaciones extends StatefulWidget {
  const CampanaNotificaciones({
    super.key,
    required this.controller,
    required this.onAbrirBandeja,
  });

  final ResumenNotificacionesController controller;
  final Future<void> Function() onAbrirBandeja;

  @override
  State<CampanaNotificaciones> createState() => _CampanaNotificacionesState();
}

class _CampanaNotificacionesState extends State<CampanaNotificaciones> {
  // Se fija al crear el estado: si la pantalla se reconstruye, se sigue
  // usando (y luego se descarta) el mismo controlador.
  late final ResumenNotificacionesController _controller = widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.alLlegarAvisos = _avisar;
    _controller.iniciar();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _avisar(List<Notificacion> nuevos, {required bool alIniciar}) {
    if (!mounted || nuevos.isEmpty) return;
    final texto = alIniciar && nuevos.length > 1
        ? '${AppStrings.notificationsPendingPrefix} ${nuevos.length} '
              '${AppStrings.notificationsPendingSuffix}'
        : nuevos
              .firstWhere((n) => n.esAlerta, orElse: () => nuevos.first)
              .titulo;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          action: SnackBarAction(
            label: AppStrings.see,
            onPressed: () => _abrir(),
          ),
        ),
      );
  }

  Future<void> _abrir() async {
    await widget.onAbrirBandeja();
    await _controller.actualizar();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final pendientes = _controller.resumen.totalNoLeidas;
        return IconButton(
          tooltip: AppStrings.notificationsTitle,
          onPressed: () => _abrir(),
          icon: Badge(
            isLabelVisible: pendientes > 0,
            label: Text(pendientes > 99 ? '99+' : '$pendientes'),
            child: Icon(
              pendientes > 0
                  ? Icons.notifications_active
                  : Icons.notifications_none,
            ),
          ),
        );
      },
    );
  }
}
