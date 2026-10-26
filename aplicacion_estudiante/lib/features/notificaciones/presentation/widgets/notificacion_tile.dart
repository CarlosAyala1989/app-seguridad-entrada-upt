import 'package:flutter/material.dart';

import '../../../../shared/l10n/app_strings.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/tarjeta_evento.dart';
import '../../domain/entities/notificacion.dart';

/// dd/mm/aaaa hh:mm en la hora del teléfono (la API envía UTC).
String fechaHoraLocal(DateTime fecha) {
  final l = fecha.toLocal();
  String dos(int n) => n.toString().padLeft(2, '0');
  return '${dos(l.day)}/${dos(l.month)}/${l.year} '
      '${dos(l.hour)}:${dos(l.minute)}';
}

/// Fila de la bandeja. Los avisos sin leer van en negrita y con un punto.
class NotificacionTile extends StatelessWidget {
  const NotificacionTile({
    super.key,
    required this.notificacion,
    required this.onTap,
  });

  final Notificacion notificacion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = notificacion;
    // Las alertas de posible uso sospechoso (US-21) se distinguen a simple
    // vista de las denegaciones normales.
    return TarjetaEvento(
      icono: n.esAlerta ? Icons.gpp_maybe : Icons.block,
      color: AppColors.rojoError,
      etiqueta: n.esAlerta ? AppStrings.securityAlert : AppStrings.accessDenied,
      titulo: n.titulo,
      subtitulo: '${n.puntoAccesoNombre} · ${fechaHoraLocal(n.registradoEn)}',
      negrita: !n.leida,
      destacada: n.esAlerta,
      marcaNoLeido: !n.leida,
      onTap: onTap,
    );
  }
}
